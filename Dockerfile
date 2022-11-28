FROM cm2network/steamcmd:root

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gosu --no-install-recommends\
    && rm -rf /var/lib/apt/lists/*  \
    && gosu nobody true

RUN mkdir -p /config \
 && chown steam:steam /config

COPY scripts/init.sh /

COPY --chown=steam:steam *.ini scripts/run.sh /home/steam/

WORKDIR /config

ENV AUTOPAUSE="true" \
    AUTOSAVEINTERVAL="300"
    PGID="1000" \
    PUID="1000"

EXPOSE 28015/udp 28016

ENTRYPOINT [ "/scripts/init.sh" ]
