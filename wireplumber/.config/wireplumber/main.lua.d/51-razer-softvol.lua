alsa_monitor.rules = alsa_monitor.rules or {}

table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "device.name", "equals", "alsa_card.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01" },
    },
  },
  apply_properties = {
    ["api.alsa.use-acp"] = false,
    ["api.alsa.soft-mixer"] = true,
  },
})

table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "equals", "alsa_output.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01.analog-stereo" },
    },
  },
  apply_properties = {
    ["api.alsa.soft-mixer"] = true,
  },
})
