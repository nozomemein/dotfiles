# Usage:
#   just git config                          # show all config with origins
#   just git set user.name "John"            # add local config
#   just git set user.email "john@example.com"
#   just git set commit.gpgsign true
#   just git unset commit.gpgsign            # remove local config

# Show git config with origins
config:
    git config --global -l --show-origin --includes

# Add a local config (e.g. just git set user.name "John")
set key value:
    git config --file ~/.gitconfig.local {{ key }} "{{ value }}"

# Remove a local config (e.g. just git unset user.name)
unset key:
    git config --file ~/.gitconfig.local --unset {{ key }}
