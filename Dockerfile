FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

# set version label
ARG BUILD_DATE
ARG OPERA_VERSION
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

RUN \
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
  curl -o \
    /tmp/chromiumffmpeg.deb -L \
    "http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-codecs-ffmpeg-extra_111.0.5563.64-0ubuntu0.18.04.5_amd64.deb" && \
  dpkg -i /tmp/chromiumffmpeg.deb && \
  mv \
    /usr/lib/chromium-browser/libffmpeg.so \
    /usr/lib/x86_64-linux-gnu/opera/libffmpeg.so && \
  sed -i \
    's|</applications>|  <application title="*Opera" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' \
    /etc/xdg/openbox/rc.xml && \
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
