FROM cm2network/steamcmd:root

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gosu --no-install-recommends\
    && rm -rf /var/lib/apt/lists/*  \
    && gosu nobody true

RUN mkdir -p /config \
 && chown steam:steam /config

COPY init.sh /

COPY --chown=steam:steam *.ini run.sh /home/steam/

WORKDIR /config

ENV AUTOPAUSE="true" \
    AUTOSAVEINTERVAL="300"

EXPOSE 7777/udp 15000/udp 15777/udp

ENTRYPOINT [ "/init.sh" ]
