# Setup zoxide if available
if type -q zoxide
  zoxide init fish | source
end

# Setup mise if available
if type -q mise
  mise activate fish | source
end

# Set default editor
set -x EDITOR nvim

# Aliases
alias g='git'
alias ld='lazydocker'

# Load local config if exists
if test -f $HOME/.config/fish/config.local.fish
  source $HOME/.config/fish/config.local.fish
end
