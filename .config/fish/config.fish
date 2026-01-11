if not status is-interactive
    exit
end

## Set values
## Run fastfetch as welcome message
function fish_greeting
    hyfetch
end

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

## Enable Wayland support for different applications
if [ "$XDG_SESSION_TYPE" = "wayland" ]
    set -gx WAYLAND 1
    set -gx QT_QPA_PLATFORM 'wayland;xcb'
    set -gx GDK_BACKEND 'wayland,x11'
    set -gx MOZ_DBUS_REMOTE 1
    set -gx MOZ_ENABLE_WAYLAND 1
    set -gx _JAVA_AWT_WM_NONREPARENTING 1
    set -gx BEMENU_BACKEND wayland
    set -gx CLUTTER_BACKEND wayland
    set -gx ECORE_EVAS_ENGINE wayland_egl
    set -gx ELM_ENGINE wayland_egl
end

set -gx PROTON_USE_NTSYNC 1

## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
    source ~/.fish_profile
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        fish_add_path ~/.local/bin
    end
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        fish_add_path ~/Applications/depot_tools
    end
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function unpackall --description "Unpacks all archive files in the current directory into their own folders."
    for file in *.*
        if test -f "$file"
            if string match -r '\.(zip|7z|rar|tar|tgz|tar\.gz|tar\.bz2|tar\.xz|gz|bz2|xz)$' -- $file
                set base (string replace -r '\.(zip|7z|rar|tar|tgz|tar\.gz|tar\.bz2|tar\.xz|gz|bz2|xz)$' '' -- $file)
                mkdir -p "$base"
                echo "Extracting $file -> $base"
                7z x -y "$file" -o"$base" >/dev/null
            end
        end
    end
end

function switchsort --description "Unpacks Switch ROMs, moves ROM files, and cleans up."
    # File extraction
    echo (set_color green)"1. Unpacking all archives..."(set_color normal)
    for file in *.{rar,zip,7z}
        # Check if the file exists before trying to extract
        if test -f "$file"
            echo "  -> Extracting "(set_color blue)"$file"(set_color normal)
            7z x -y "$file" >/dev/null # Suppress output
        end
    end

    echo (set_color green)"2. Moving ROM files files to the current folder..."(set_color normal)
    # Use -nv for no-clobber (don't overwrite) and verbose output
    find . -mindepth 2 -iname '*.nsp' -exec mv -nv -t . {} +
    find . -mindepth 2 -iname '*.xci' -exec mv -nv -t . {} +

    echo (set_color green)"3. Cleaning up junk files and empty folders..."(set_color normal)
    # Delete .url files first
    find . -type f -name '*.url' -delete
    find . -type f -name '*.URL' -delete
    # Then delete the now-empty directories
    find . -mindepth 1 -type d -empty -delete

    echo (set_color B000B5)"✨ Done! ✨"(set_color normal)
end

function updateall --description "Updates EVERYTHING"
    sudo echo e && flatpak update -y && flutter upgrade && yay --noconfirm && sudo shutdown now
end

## Useful aliases
# Shortcut to my second drive
alias nbm='cd /mnt/nyaboom'

# Replace ls with eza
alias ls='eza -al --color=always --group-directories-first --icons' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons'  # long format
alias tree='eza -aT --color=always --group-directories-first --icons' # tree listing

# Common use
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias untar='tar -zxvf '
alias wget='wget -c '
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'
alias big="expac -H M '%m\t%n' | sort -h | nl" # Sort installed packages according to size in MB
alias up='yay -Syu'
alias ayy='yay -S '
alias pub='flutter pub'

# NeoBim
alias nano='nvim'
alias vi='nvim'
alias vim='nvim'

# Get fastest mirrors
alias mirrors="sudo cachyos-rate-mirrors"

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# Millennium (steam package manager)
fish_add_path /home/nyx/.millennium/ext/bin 

fish_add_path /mnt/nyaboom/Projects/website/functions/external-bin

# Flutter
fish_add_path -g -p ~/development/flutter/bin

# Android SDK
set --export ANDROID_HOME "$HOME/Android/Sdk"
set --export ANDROID_SDK_ROOT "$HOME/Android/Sdk"
set --export CHROME_EXECUTABLE "thorium-browser"
fish_add_path /home/nyx/Android/Sdk/ndk/29.0.13599879

set --export PROTON_ENABLE_WAYLAND 1

set --export JAVA_HOME "/usr/lib/jvm/java-21-temurin/"

# n³
export NNN_PLUG="y:xdgdefault"
set --export NNN_FIFO "/tmp/nnn.fifo"

# UV
set --export UV_CACHE_DIR "/mnt/nyaboom/.uv"

# DevKitPro
set --export DEVKITPRO /opt/devkitpro
set --export DEVKITARM /opt/devkitpro/devkitARM
set --export DEVKITPPC /opt/devkitpro/devkitPPC

set -U fish_key_bindings fish_default_key_bindings
