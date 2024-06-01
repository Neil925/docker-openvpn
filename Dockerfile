FROM ubuntu:20.04

VOLUME /downloads
VOLUME /config
VOLUME /app

ENV DEBIAN_FRONTEND noninteractive

RUN usermod -u 99 nobody

# Update packages and install software
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils openssl \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:qbittorrent-team/qbittorrent-stable \
    && apt-get update \
    && apt-get install -y qbittorrent-nox openvpn curl moreutils net-tools dos2unix kmod iptables ipcalc unrar wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Prowlarr
RUN \
  echo "**** install prowlarr ****" && \
  mkdir -p /app/prowlarr/bin && \
  curl -o \
    /tmp/prowlarr.tar.gz -L \
    "https://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64" && \
  tar xzf \
    /tmp/prowlarr.tar.gz -C \
    /app/prowlarr/bin --strip-components=1 && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

# Add configuration and scripts
ADD openvpn/ /etc/openvpn/
ADD qbittorrent/ /etc/qbittorrent/

RUN chmod +x /etc/qbittorrent/*.sh /etc/qbittorrent/*.init /etc/openvpn/*.sh

# Expose ports and run
EXPOSE 8080
EXPOSE 8080/udp
EXPOSE 8999
EXPOSE 8999/udp
EXPOSE 9696
EXPOSE 9696/udp

CMD ["/bin/bash", "/etc/openvpn/start.sh"]
