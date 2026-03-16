source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

set -g fish_color_autosuggestion 5e81ac
set -g fish_color_command 88c0d0 --bold
starship init fish | source
