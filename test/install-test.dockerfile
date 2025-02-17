FROM ubuntu:noble 

RUN apt-get update && apt-get -y upgrade && apt-get -y install wget sudo tzdata cron python3-minimal
RUN useradd  -m testuser
RUN usermod -aG sudo testuser
RUN echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /etc/NetworkManager/system-connections
RUN touch /etc/NetworkManager/system-connections/Connection1.nmconnection
RUN touch /etc/NetworkManager/system-connections/Some\ Connection.nmconnection
RUN touch /etc/NetworkManager/system-connections/Some\ Other\ Connection.nmconnection
USER testuser
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam
COPY entrypoint.sh /home/testuser
COPY install-test.sh /home/testuser
WORKDIR /home/testuser
RUN ls -al
RUN mkdir .config
ENTRYPOINT ["./entrypoint.sh"]
