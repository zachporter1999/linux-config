FROM archlinux:latest
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm sudo git

#FROM fedora:35
#RUN yum update -y
#RUN yum install -y sudo git

#FROM ubuntu:20.04
#RUN apt update -y
#RUN apt install -y sudo git

RUN useradd -m -G wheel -s /bin/bash user && echo "user:user" | chpasswd #&& adduser user sudo
RUN echo 'user ALL=(ALL:ALL) ALL' >> /etc/sudoers
USER user
WORKDIR /tmp
