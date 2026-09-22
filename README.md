# dotfiles

Configs live under [`.config/`](.config/). On a new machine I clone this repo to
`~/.dotfiles` and symlink the bits I want into `~/.config`.

## Screenshots
TODO

## Install (symlink)

```fish
git clone https://github.com/nyxiereal/dotfiles.git ~/.dotfiles
mkdir -p ~/.config

# Apps to link (edit this list per machine)
set apps fish kitty fastfetch nvim quickshell wofi mako eza qt5ct qt6ct Kvantum

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
```

After linking fish, install Fisher plugins (below), then open a new terminal.

To update later: `cd ~/.dotfiles && git pull`.

## Fish plugins

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install franciscolourenco/done
fisher install jorgebucaran/autopair.fish
fisher install nickeb96/puffer-fish
fisher install IlanCosman/tide@v6
tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time=No --rainbow_prompt_separators=Slanted --powerline_prompt_heads=Slanted --powerline_prompt_tails=Slanted --powerline_prompt_style='Two lines, character' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Dark --prompt_spacing=Sparse --icons='Many icons' --transient=No
```
