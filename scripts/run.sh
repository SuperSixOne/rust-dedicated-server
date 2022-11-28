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

exec ./Engine/Binaries/Linux/UE4Server-Linux-Shipping FactoryGame -log -NoSteamClient -unattended ?listen -Port="$SERVERGAMEPORT" -BeaconPort="$SERVERBEACONPORT" -ServerQueryPort="$SERVERQUERYPORT" -multihome="$SERVERIP" "$@"

exec /app/server/RustDedicated -batchmode -nographics \
    -server.ip 0.0.0.0 \
    -server.port="$SERVERGAMEPORT" \
    -rcon.ip 0.0.0.0 \
    -rcon.port 28016 \
    -rcon.password "goodpassword" \
    -server.maxplayers 50 \
    -server.hostname "Server Name" \
    -server.identity "docker" \
    -server.level "Procedural Map" \
    -server.seed 123456 \
    -server.worldsize 3000 \
    -server.saveinterval 300 \
    -server.globalchat true \
    -server.description "Description Here"
