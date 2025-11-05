# Init zoxide
eval "$(zoxide init zsh)"

# Init mise
eval "$(mise activate zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load and initialize completion system
autoload -Uz compinit && compinit

# Install Zinit if it's not there yet
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Unalias zi for zoxide to work properly
zinit ice atload'unalias zi'

zinit light ohmyzsh/ohmyzsh
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Load local zshrc if exists
[[ -s $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# GPG TTY config for passprhase prompt
export GPG_TTY=$TTY

# Git alias
alias g='git'

# Enable substitution in the prompt
setopt prompt_subst
