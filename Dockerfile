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

# Install Jackett
RUN \
  echo "**** install jackett ****" && \
  mkdir -p /app/jackett/ && \
  cd /app/jackett/ && \
  f=Jackett.Binaries.LinuxAMDx64.tar.gz && \
  wget -Nc https://github.com/Jackett/Jackett/releases/latest/download/"$f" && \
  tar -xzf "$f" && \
  rm -f "$f" && \
  mv Jackett*/ ./bin

# Add configuration and scripts
ADD openvpn/ /etc/openvpn/
ADD qbittorrent/ /etc/qbittorrent/
ADD jackett /etc/jackett/

RUN chmod +x /etc/qbittorrent/*.sh /etc/qbittorrent/*.init /etc/openvpn/*.sh /etc/jackett/*.sh /etc/jackett/*.init

# Expose ports and run
EXPOSE 8080
EXPOSE 8080/udp
EXPOSE 8999
EXPOSE 8999/udp
EXPOSE 9117
EXPOSE 9117/udp

CMD ["/bin/bash", "/etc/openvpn/start.sh"]
