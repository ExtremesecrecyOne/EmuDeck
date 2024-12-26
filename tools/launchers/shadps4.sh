#!/bin/bash
source $HOME/.config/EmuDeck/backend/functions/all.sh
emulatorInit "shadps4"
emuName="Shadps4-qt" #parameterize me
emufolder="$HOME/Applications" # has to be applications for ES-DE to find it

#initialize execute array
exe=()

#find full path to emu executable
exe_path=$(find "$emufolder" -iname "${emuName}*.AppImage" | sort -n | cut -d' ' -f 2- | tail -n 1 2>/dev/null)

#if appimage doesn't exist fall back to flatpak.
if [[ -z "$exe_path" ]]; then
    #flatpak
    flatpakApp=$(flatpak list --app --columns=application | grep "$RPCS3_emuPathFlatpak")
    #fill execute array
    exe=("flatpak" "run" "$flatpakApp")
else
    #make sure that file is executable
    chmod +x "$exe_path"
    #fill execute array
    exe=("$exe_path")
fi

fileExtension="${@##*.}"

if [[ $fileExtension == "desktop" ]]; then
    rpcs3desktopFile=$(grep -E "^Exec=" "${*}" | sed 's/^Exec=//' | sed 's/%%/%/g')
    launchParam="Exec=$rpcs3desktopFile"
    launchParam=$(echo "$launchParam" | sed "s|^\(Exec=\)[^\"']*\"|\1$HOME/Applications/Shadps4-qt.AppImage\"|")
    eval $launchParam
else
    #run the executable with the params.
    launch_args=()
    for rom in "${@}"; do
        # Parsers previously had single quotes ("'/path/to/rom'" ), this allows those shortcuts to continue working.
        removedLegacySingleQuotes=$(echo "$rom" | sed "s/^'//; s/'$//")
        launch_args+=("$removedLegacySingleQuotes")
    done

    echo "Launching: ${exe[*]} ${launch_args[*]}"

    if [[ -z "${*}" ]]; then
        echo "ROM not found. Launching $emuName directly"
        "${exe[@]}"
    else
        echo "ROM found, launching game"
        "${exe[@]}" "${launch_args[@]}"
    fi
fi

rm -rf "$savesPath/.gaming"
