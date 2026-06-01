# Init zoxide
eval "$(zoxide init zsh)"

# Init mise if available
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
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

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Load local zshrc if exists
[[ -s $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# GPG TTY config for passprhase prompt
export GPG_TTY=$TTY

# Git alias
alias g='git'

# Lazydocker alias
alias ld='lazydocker'

# Set default editor
export EDITOR='nvim'

# Enable substitution in the prompt
setopt prompt_subst

# Init Starship
eval "$(starship init zsh)"
