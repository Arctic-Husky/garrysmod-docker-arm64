FROM docker.io/sonroyaalmerol/steamcmd-arm64:latest

LABEL maintainer="caiofonsecaprofissional@gmail.com"

USER root

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    net-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER steam

# DOWNLOAD GMOD SERVER
COPY assets/update.txt ${HOMEDIR}/update.txt
RUN ${STEAMCMDDIR}/steamcmd.sh +runscript ${HOMEDIR}/update.txt +quit

# # SETUP BINARIES FOR x32 and x64 bits
# RUN mkdir -p /home/steam/.steam/sdk32 \
#     && cp -v /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so \
#     && mkdir -p /home/steam/.steam/sdk64 \
#     && cp -v /home/steam/steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

# # SETUP CSS CONTENT
# RUN ${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${HOMEDIR}/temp \
#     +login anonymous \
#     +app_update 232330 validate \
#     +quit
# RUN mkdir ${HOMEDIR}/mounts && mv ${HOMEDIR}/temp/cstrike ${HOMEDIR}/mounts/cstrike
# RUN rm -rf ${HOMEDIR}/temp

# # SET GMOD MOUNT CONTENT
# RUN echo '"mountcfg" {"cstrike" "/home/steam/mounts/cstrike"}' > ${HOMEDIR}/server/garrysmod/cfg/mount.cfg

# # CREATE DATABASE FILE
# RUN touch ${HOMEDIR}/server/garrysmod/sv.db

# # CREATE CACHE FOLDERS
# RUN mkdir -p ${HOMEDIR}/server/steam_cache/content && mkdir -p ${HOMEDIR}/server/garrysmod/cache/srcds

# PORT FORWARDING
# https://developer.valvesoftware.com/wiki/Source_Dedicated_Server#Connectivity
EXPOSE 27015
EXPOSE 27015/udp
EXPOSE 27005/udp

# SET ENVIRONMENT VARIABLES
ENV MAXPLAYERS="16"
ENV GAMEMODE="sandbox"
ENV MAP="gm_construct"
ENV PORT="27015"

ENV BOX64_DYNAREC_BIGBLOCK=0
ENV BOX64_DYNAREC_SAFEFLAGS=2
ENV BOX64_DYNAREC_STRONGMEM=3
ENV BOX64_DYNAREC_FASTROUND=0
ENV BOX64_DYNAREC_FASTNAN=0
ENV BOX64_DYNAREC_X87DOUBLE=1
ENV BOX64_PREFER_EMULATED=1

ENV ARM64_DEVICE=adlink

# ADD START SCRIPT
COPY --chown=steam:steam assets/start.sh ${HOMEDIR}/start.sh
RUN chmod +x ${HOMEDIR}/start.sh

# CREATE HEALTH CHECK
COPY --chown=steam:steam assets/health.sh ${HOMEDIR}/health.sh
RUN chmod +x ${HOMEDIR}/health.sh
HEALTHCHECK --start-period=10s \
    CMD ${HOMEDIR}/health.sh

# ADD WRAPPER SCRIPT
COPY --chown=steam:steam assets/srcds_box64_wrapper ${HOMEDIR}/server/srcds_box64_wrapper
RUN chmod +x ${HOMEDIR}/server/srcds_box64_wrapper

# START THE SERVER
CMD ["/home/steam/start.sh"]