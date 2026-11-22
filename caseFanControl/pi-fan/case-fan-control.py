#!/usr/bin/python3 -I
"""Freenove FNK0100 case fans: run only when the CPU is actually hot.

Off below ON_TEMP; once on, stays on until the CPU drops below OFF_TEMP
(hysteresis, so the fans don't keep starting and stopping).
On stop/shutdown fans and case LEDs are switched off.
Also keeps the case LEDs solid red (the board does not keep it after power cycles).

Song colour: while pi-shazam plays a song it writes the artwork colour as
"rrggbb" to /run/pishazam/led_color, and the LEDs take that colour. No file
(no song, between songs, pi-shazam stopped) or a bad one = solid red.
Colours are gamma-corrected before they reach the LEDs: "rrggbb" is a
screen colour (sRGB), but LED brightness is linear, so a half-strength
channel looks far brighter on an LED than on a screen and pastel/washed-out
colours result (#ff7b85, salmon on screen, looks pale pink-white). With
LED_GAMMA it shows as ~#ff333d instead. Pure primaries (#ff0000) are
unchanged. Colour changes fade over LED_FADE seconds; waking from standby fades in
from black. Going to standby switches the LEDs off at once.

Standby: while /run/pishazam/standby exists (pi-shazam creates it when the
touch screen is double-tapped) the case LEDs are switched off. This script
stays the only writer to the board; pi-shazam never touches I2C 0x21.
Fans keep following the CPU temperature in standby. systemd removes
/run/pishazam when pi-shazam stops, so the LEDs can't stay off by mistake.
"""
import fcntl, os, signal, sys, time

BUS, ADDR = "/dev/i2c-1", 0x21
REG_LED_ALL, REG_LED_MODE = 0x02, 0x03
REG_FAN_MODE, REG_FAN_DUTY = 0x04, 0x06
LED_RGB = (255, 0, 0)  # default: all case LEDs solid red
LED_REFRESH = 60      # re-apply LEDs every N seconds (board forgets on power cycle)
I2C_SLAVE = 0x0703
CPU_TEMP = "/sys/class/thermal/thermal_zone0/temp"

ON_TEMP = 70.0    # start fans at this CPU temperature (C)
OFF_TEMP = 62.0   # stop fans once back below this
# (CPU temp C, duty 0-255): highest matching row wins
CURVE = [(0, 110), (75, 170), (80, 255)]
INTERVAL = 5
STANDBY_FLAG = "/run/pishazam/standby"
FLAG_POLL = 0.5   # how often the standby flag and LED colour are checked (s)
COLOR_FILE = "/run/pishazam/led_color"
LED_GAMMA = 2.2  # screen colour -> LED drive level; 1.0 = no correction
LED_FADE = 5.0    # colour transitions take this long (s)
FADE_STEP = 0.1   # LED update period while fading (s); each write takes ~0.05 s

fd = os.open(BUS, os.O_RDWR)
fcntl.ioctl(fd, I2C_SLAVE, ADDR)


def write(*data):
    os.write(fd, bytes(data))
    time.sleep(0.05)


def set_duty(d):
    write(REG_FAN_DUTY, d, d)


def wanted_color():
    """The song colour pi-shazam asked for, or the default red."""
    try:
        with open(COLOR_FILE) as f:
            h = f.read().strip()
        if len(h) == 6:
            return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
    except (OSError, ValueError):
        pass
    return LED_RGB


def to_led(rgb):
    return tuple(round(255 * (ch / 255) ** LED_GAMMA) for ch in rgb)


def set_leds(rgb):
    write(REG_LED_MODE, 1)  # 1 = solid colour
    write(REG_LED_ALL, *to_led(rgb))


def set_rgb(rgb):
    write(REG_LED_ALL, *to_led(rgb))  # colour only: the mode is already "solid"


def mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def leds_off():
    write(REG_LED_MODE, 0)  # 0 = LEDs off


def cpu_temp():
    with open(CPU_TEMP) as f:
        return int(f.read()) / 1000


def stop(*_):
    try:
        set_duty(0)
        write(REG_FAN_MODE, 0)
        leds_off()  # the board stays powered after poweroff
    finally:
        sys.exit(0)


def check_fans():
    global running, last
    t = cpu_temp()
    if t >= ON_TEMP:
        running = True
    elif t < OFF_TEMP:
        running = False
    duty = max(d for th, d in CURVE if t >= th) if running else 0
    if duty != last:
        set_duty(duty)
        print(f"CPU {t:.1f}C -> fan duty {duty}", flush=True)
        last = duty


signal.signal(signal.SIGTERM, stop)
signal.signal(signal.SIGINT, stop)

write(REG_FAN_MODE, 1)  # manual mode: duty set by us
running, last, led_at, standby = False, None, -LED_REFRESH, None
temp_at = -INTERVAL
# LED fade: `shown` is on the LEDs now, moving from `fade_from` to `target`
shown = fade_from = target = (0, 0, 0)
fade_at = 0.0
while True:
    pause = FLAG_POLL
    try:
        now = time.monotonic()
        now_standby = os.path.exists(STANDBY_FLAG)
        now_color = wanted_color()
        if now_standby != standby:
            if now_standby:
                leds_off()
            else:
                shown = (0, 0, 0)
                set_leds(shown)  # fade in from black
                fade_from, target, fade_at = shown, now_color, now
                led_at = now
            print(f"standby {'on: LEDs off' if now_standby else 'off: LEDs on'}", flush=True)
            standby = now_standby
        if not standby:
            if now_color != target:
                print("LEDs -> #%02x%02x%02x" % now_color, flush=True)
                fade_from, target, fade_at = shown, now_color, now  # also restarts a fade midway
            if shown != target:
                rgb = mix(fade_from, target, min(1.0, (now - fade_at) / LED_FADE))
                if rgb != shown:
                    set_rgb(rgb)
                    shown = rgb
                pause = FADE_STEP
            elif now - led_at >= LED_REFRESH:
                set_leds(shown)
                led_at = now
        if time.monotonic() - temp_at >= INTERVAL:
            temp_at = time.monotonic()
            check_fans()
    except OSError as e:
        # Can't talk to the board or read temp: fail safe, try full speed
        print(f"error: {e}; trying full speed", flush=True)
        try:
            set_duty(255)
        except OSError:
            pass
        last = None
        standby = None  # re-apply the LED state once the board answers again
    time.sleep(pause)
