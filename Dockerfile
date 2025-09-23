FROM docker.io/sonroyaalmerol/steamcmd-arm64:latest

LABEL maintainer="caiofonsecaprofissional@gmail.com"

USER root

RUN sudo apt-get update && apt-get install -y --no-install-recommends \
    libc6:i386 lsb-core \
    lib32z1 \
    ia32-libs \
    && apt install build-essential

USER steam

ENV USER steam
ENV HOMEDIR "/home/${USER}"
ENV STEAMCMDDIR "${HOMEDIR}/steamcmd"

# DOWNLOAD GMOD SERVER
COPY assets/update.txt ${HOMEDIR}/update.txt
RUN ${STEAMCMDDIR}/steamcmd.sh +runscript ${HOMEDIR}/update.txt +quit

# SETUP CSS CONTENT
RUN ${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${HOMEDIR}/temp \
    +login anonymous \
    +app_update 232330 validate \
    +quit
RUN mkdir ${HOMEDIR}/mounts && mv ${HOMEDIR}/temp/cstrike ${HOMEDIR}/mounts/cstrike
RUN rm -rf ${HOMEDIR}/temp

# SET GMOD MOUNT CONTENT
RUN echo '"mountcfg" {"cstrike" "/home/steam/mounts/cstrike"}' > ${HOMEDIR}/server/garrysmod/cfg/mount.cfg

# CREATE DATABASE FILE
RUN touch ${HOMEDIR}/server/garrysmod/sv.db

# CREATE CACHE FOLDERS
RUN mkdir -p ${HOMEDIR}/server/steam_cache/content && mkdir -p ${HOMEDIR}/server/garrysmod/cache/srcds

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