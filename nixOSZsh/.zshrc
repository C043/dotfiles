# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k" # set by `omz`
DEFAULT_USER=$USER
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
[[ -r /etc/zsh_command_not_found ]] && source /etc/zsh_command_not_found

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
setopt CORRECT
setopt extended_glob
setopt dot_glob
set -o vi

alias rcopy="rsync -avvzh --no-o --no-g --delete --update --progress --partial"
alias leetcode="nvim leetcode.nvim"
alias prod="productivity.sh && exit"
alias img="img.sh"
alias window="window.sh && exit"
alias wa="whatsapp.sh && exit"
alias sp="speech.sh && exit"
alias airplay="uxPlay.sh && exit"
alias ssh="kitty +kitten ssh"
alias todo="todo.sh"
alias newsletter="newsletter.sh"
alias vault="vault.sh"
alias browser="vivaldi.vivaldi-stable"
alias sysupdate="sudo nix-channel --update && sudo nixos-rebuild switch --upgrade"
alias prunNix="sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +10 && sudo nix-store --gc"
alias feh="feh --auto-zoom --scale-down"
alias fj="forgejo.sh"

openpdf() {
    nohup zathura "$@" >/dev/null 2>&1 &
    disown
    exit
}

git() {
    if [[ "$1" == "push" ]]; then
        shift
        pushSwitch.sh "$@"
    elif [[ "$1" == "pull" ]]; then
        shift
        pullSwitch.sh "$@"
    else
        command git "$@"
    fi
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export EDITOR=vim

# Created by `pipx` on 2024-12-16 09:50:43
export PATH="$PATH:/home/c043/.local/bin"
export PATH="$PATH:/run/media/c043/Drive/EPICODE/c043-scripts"
export PATH="$PATH:/home/c043/.platformio/penv/bin"
export PATH="$PATH:/snap/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export JAVA_HOME="/opt/jdk-21.0.4+7/"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/.local/tea/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Abilita keybindings e completions per fzf
# fzf integration on NixOS
if command -v fzf >/dev/null 2>&1; then
    fzf_base="$(dirname "$(dirname "$(readlink -f "$(command -v fzf)")")")"

    [[ -r "$fzf_base/share/fzf/key-bindings.zsh" ]] && source "$fzf_base/share/fzf/key-bindings.zsh"
    [[ -r "$fzf_base/share/fzf/completion.zsh" ]] && source "$fzf_base/share/fzf/completion.zsh"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
