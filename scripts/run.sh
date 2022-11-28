#!/bin/bash

set -e

if ! [[ "${SKIPUPDATE,,}" == "true" ]]; then
    if [[ "${STEAMBETA,,}" == "true" ]]; then
        printf "Experimental flag is set. Experimental will be downloaded instead of Early Access.\\n"
        STEAMBETAFLAG=" -beta experimental validate"
    fi

    space=$(stat -f --format="%a*%S" .)
    space=$((space/1024/1024/1024))
    printf "Checking available space...%sGB detected\\n" "${space}"

    if [[ "$space" -lt 5 ]]; then
        printf "You have less than 5GB (%sGB detected) of available space to download the game.\\nIf this is a fresh install, it will probably fail.\\n" "${space}"
    fi

    printf "Downloading the latest version of the game...\\n"

    /home/steam/steamcmd/steamcmd.sh +force_install_dir /config/gamefiles +login anonymous +app_update "$STEAMAPPID" $STEAMBETAFLAG +quit
else
    printf "Skipping update as flag is set\\n"
fi

cp -a "/config/saves/." "/config/backups/"
cp -a "${GAMESAVESDIR}/server/." "/config/backups" # useless in first run, but useful in additional runs
rm -rf "${GAMESAVESDIR}/server"
ln -sf "/config/saves" "${GAMESAVESDIR}/server"
ln -sf "/config/ServerSettings.${SERVERQUERYPORT}" "${GAMESAVESDIR}/ServerSettings.${SERVERQUERYPORT}"

cp /home/steam/*.ini "${GAMECONFIGDIR}/Config/LinuxServer"

if [ ! -f "/config/gamefiles/Engine/Binaries/Linux/UE4Server-Linux-Shipping" ]; then
    printf "Game binary is missing.\\n"
    exit 1
fi

cd /config/gamefiles || exit 1

exec ./Engine/Binaries/Linux/UE4Server-Linux-Shipping FactoryGame -log -NoSteamClient -unattended ?listen -Port="$SERVERGAMEPORT" -BeaconPort="$SERVERBEACONPORT" -ServerQueryPort="$SERVERQUERYPORT" -multihome="$SERVERIP" "$@"
