# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


ZSH='/home/c043/.oh-my-zsh'
ZSH_THEME='powerlevel10k/powerlevel10k'
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)
source /home/c043/.oh-my-zsh/oh-my-zsh.sh

set -o vi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf key bindings & completion from the distro examples
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

export PATH="$HOME/bin:$PATH"

