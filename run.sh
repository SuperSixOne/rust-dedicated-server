#!/bin/bash
set -e

# change the working directory
cd "${GAMEFILESDIR}"

# construction logic
if ! [[ "${SKIPUPDATE,,}" == "true" ]]; then
    if [[ "${STEAMBETA,,}" == "true" ]]; then
        printf "Staging flag is set. Staging will be downloaded instead of Main.\\n"
        STEAMBETAFLAG=" -beta staging validate"
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

# Create variable for log string
now=$(date +"%Y-%m-%d-%H-%M-%S")

# start the server
exec "${GAMEFILESDIR}/RustDedicated" batchmode \
+server.port $SERVERPORT \
+server.worldsize $SERVERWORLDSIZE \
+server.maxplayers $MAXPLAYERS \
+server.hostname "${SERVERHOSTNAME}" \
+server.description "${SERVERDESCRIPTION}" \
+server.saveinterval $SERVERSAVEINTERVAL \
+server.seed $SERVERSEED \
+server.identity "docker" \
+rcon.port $RCONSERVERPORT \
+rcon.password "${RCONSERVERPASSWORD}" \
+rcon.web $RCONMODE \
logfile "${GAMELOGDIR}/${now}.txt"