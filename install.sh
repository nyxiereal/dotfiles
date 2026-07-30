#!/bin/fish
git clone https://github.com/nyxiereal/dotfiles.git ~/.dotfiles
mkdir -p ~/.config

# Apps to link (edit this list per machine)
set apps fish kitty fastfetch nvim quickshell wofi mako eza qt5ct qt6ct Kvantum opencode

for app in $apps
    set -l src ~/.dotfiles/.config/$app
    set -l dst ~/.config/$app
    if test -e $dst -o -L $dst
        echo "skip $app (already exists at $dst) — move it aside first"
        continue
    end
    ln -s $src $dst
    echo "linked $app"
end

# Loose files (not directories)
ln -sf ~/.dotfiles/.config/hyfetch.json ~/.config/hyfetch.json