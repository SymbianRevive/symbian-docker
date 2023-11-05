FROM debian:trixie-20231030-slim

COPY external/Nokia_Symbian_Belle_SDK_v1.0/ /var/tmp/Nokia_Symbian_Belle_SDK_v1.0
COPY external/gcc-12.1.0/ /var/tmp/gcc-12.1.0

COPY rt/symbian-env.sh /etc/profile.d/symbian-env.sh

COPY build/build-container.sh /var/tmp/build-container.sh

COPY rt/autocmake /usr/local/bin/autocmake
COPY rt/autocmake.py /usr/local/libexec/autocmake.py

RUN /var/tmp/build-container.sh
RUN rm -rf /var/tmp/*
