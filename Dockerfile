FROM cm2network/steamcmd:root

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gosu --no-install-recommends \ 
        sqlite3 \
    && rm -rf /var/lib/apt/lists/*  \
    && gosu nobody true

RUN mkdir -p /config \
 && chown steam:steam /config

COPY --chmod=755 init.sh /

COPY --chown=steam:steam run.sh /home/steam/

WORKDIR /config

ENV STEAMAPPID="258550" \
    SKIPUPDATE="false" \
    STEAMBETA="false" \
    PGID="1000" \
    PUID="1000" \
    GAMEFILESDIR="/config/gamefiles" \
    GAMELOGDIR="/config/logs" \
    MAXPLAYERS="50" \
    SERVERHOSTNAME="" \
    SERVERDESCRIPTION="" \
    SERVERWORLDSIZE=3000 \
    SERVERSEED=50000 \
    SERVERSAVEINTERVAL=600 \
    SERVERPORT=28015 \
    RCONSERVERPORT=28016 \
    RCONSERVERPASSWORD="" \
    RCONMODE=1

EXPOSE 28015/udp 28016

ENTRYPOINT [ "/init.sh" ]