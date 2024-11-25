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

zinit light ohmyzsh/ohmyzsh
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# GPG TTY config for passprhase prompt
export GPG_TTY=$TTY

# Enable substitution in the prompt.
setopt prompt_subst

# Load RVM if installed
[[ -s '/etc/profile.d/rvm.sh' ]] && source '/etc/profile.d/rvm.sh'

# Load NVM if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load custom profile if exists
[[ -s $HOME/.custom-profile ]] && source $HOME/.custom-profile

# Custom aliases
alias gpull='git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gpush='git push origin $(git rev-parse --abbrev-ref HEAD)'
alias gpushf='git push -f origin $(git rev-parse --abbrev-ref HEAD)'

# NVIM NEW
alias nvimn='NVIM_APPNAME=nvim-new nvim'

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
