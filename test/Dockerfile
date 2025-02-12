FROM ubuntu:noble 

RUN apt-get update && apt-get -y install wget sudo
RUN useradd  -m testuser
RUN usermod -aG sudo testuser
RUN echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser


