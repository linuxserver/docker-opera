FROM ghcr.io/linuxserver/baseimage-selkies:debianbookworm

# set version label
ARG BUILD_DATE
ARG OPERA_VERSION
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Opera

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/opera-icon.png && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    gsettings-desktop-schemas && \
  echo "**** install opera ****" && \
  if [ -z ${OPERA_VERSION+x} ]; then \
    OPERA_VERSION=$(curl -sL https://deb.opera.com/opera-stable/dists/stable/non-free/binary-amd64/Packages \
    | awk -F ': ' '/opera-stable/{ getline; print $2; exit}'); \
  fi && \
  curl -o \
    /tmp/opera.deb -L \
    "https://deb.opera.com/opera-stable/pool/non-free/o/opera-stable/opera-stable_${OPERA_VERSION}_amd64.deb" && \
  DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y /tmp/opera.deb && \
  echo "**** opera docker tweaks ****" && \
  mv \
    /usr/bin/opera \
    /usr/bin/opera-real && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
