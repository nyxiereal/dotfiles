## Environment
set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx ANDROID_SDK_ROOT "$ANDROID_HOME"
set -gx CHROME_EXECUTABLE thorium-browser
set -gx PROTON_USE_NTSYNC 1
set -gx PROTON_ENABLE_WAYLAND 1
set -gx JAVA_HOME /usr/lib/jvm/java-21-temurin
set -gx UV_CACHE_DIR /mnt/nyaboom/.uv
set -gx DEVKITPRO /opt/devkitpro
set -gx DEVKITARM /opt/devkitpro/devkitARM
set -gx DEVKITPPC /opt/devkitpro/devkitPPC
set -gx OPENCODE_EXPERIMENTAL_WEBSOCKETS true
set -U fish_key_bindings fish_default_key_bindings

# Latest installed NDK - Gradle/Flutter use the project's ndkVersion;
# ANDROID_NDK_HOME is for ndk-build / CMake / tooling that still expect it.
if test -d "$ANDROID_HOME/ndk"
    set -l latest (ls "$ANDROID_HOME/ndk" | sort -V | tail -1)
    set -gx ANDROID_NDK_HOME "$ANDROID_HOME/ndk/$latest"
end

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.bun/bin
fish_add_path -g -p ~/development/flutter/bin
test -d $HOME/Applications/depot_tools; and fish_add_path $HOME/Applications/depot_tools
test -d "$ANDROID_HOME/platform-tools"; and fish_add_path "$ANDROID_HOME/platform-tools"

if test -f ~/.fish_profile
    source ~/.fish_profile
end

## Wayland
if test "$XDG_SESSION_TYPE" = wayland
    set -gx WAYLAND 1
    set -gx QT_QPA_PLATFORM 'wayland;xcb'
    set -gx GDK_BACKEND 'wayland,x11'
    set -gx MOZ_ENABLE_WAYLAND 1
    set -gx _JAVA_AWT_WM_NONREPARENTING 1
    set -gx BEMENU_BACKEND wayland
    set -gx CLUTTER_BACKEND wayland
    set -gx ECORE_EVAS_ENGINE wayland_egl
    set -gx ELM_ENGINE wayland_egl
end

status is-interactive; or exit

## Interactive only
function fish_greeting
    hyfetch
end

# done plugin - set once (universal vars persist across shells)
if not set -q __done_min_cmd_duration
    set -U __done_min_cmd_duration 10000
    set -U __done_notification_urgency_level low
end

# Kitty (keyboard protocol) binds ctrl-backspace → backward-kill-token, which
# wipes a whole path. Cursor's terminal often behaves like path-component delete.
# Match that: one path segment per ctrl-backspace.
bind ctrl-backspace backward-kill-path-component

function history
    builtin history --show-time='%F %T '
end

function unpackall --description "Unpack archives in cwd into their own folders"
    for file in *.*
        if test -f "$file"
            and string match -qr '\.(zip|7z|rar|tar|tgz|tar\.gz|tar\.bz2|tar\.xz|gz|bz2|xz)$' -- $file
            set -l base (string replace -r '\.(zip|7z|rar|tar|tgz|tar\.gz|tar\.bz2|tar\.xz|gz|bz2|xz)$' '' -- $file)
            mkdir -p "$base"
            echo "Extracting $file -> $base"
            7z x -y "$file" -o"$base" >/dev/null
        end
    end
end

function updateall --description "Upgrade Flutter + system packages, then shut down"
    sudo true
    and flutter upgrade
    and yay --noconfirm
    and sudo shutdown now
end

function qs-restart --description "Restart quickshell"
    killall quickshell 2>/dev/null
    quickshell &; disown
end

function adb-install-all --description "Install APK on all adb devices (+ waydroid)"
    if not test -f "$argv[1]"
        echo "Usage: adb-install-all <path-to-apk>"
        return 1
    end

    for serial in (adb devices | awk '/\tdevice$/{print $1}')
        echo ">> Device: $serial"
        adb -s $serial install -r "$argv[1]"
    end
    if pgrep -x waydroid >/dev/null
        echo ">> Waydroid"
        waydroid app install "$argv[1]"
    end
end

alias ls='eza -al --color=always --group-directories-first --icons=always --hyperlink=auto --time-style=relative --git'
alias la='eza -a --color=always --group-directories-first --icons=always --hyperlink=auto'
alias ll='eza -l --color=always --group-directories-first --icons=always --hyperlink=auto --time-style=relative --git'
alias tree='eza -aT --color=always --group-directories-first --icons=always --hyperlink=auto --time-style=relative'

alias fixpac='sudo rm /var/lib/pacman/db.lck'
alias untar='tar -zxvf'
alias wget='wcurl'
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias up='yay -Syu'
alias ayy='yay -S'
alias pub='flutter pub'

alias nano='nvim'
alias vi='nvim'
alias vim='nvim'

alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
