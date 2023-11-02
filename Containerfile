FROM debian:trixie-20231030-slim

COPY external/Nokia_Symbian_Belle_SDK_v1.0/ /var/tmp/Nokia_Symbian_Belle_SDK_v1.0
COPY external/gcc-12.1.0/ /var/tmp/gcc-12.1.0

COPY build/build-container.sh /var/tmp/build-container.sh
COPY build/autocmake /usr/local/bin/autocmake
COPY build/autocmake.py /usr/local/libexec/autocmake.py

RUN /var/tmp/build-container.sh
RUN rm -rf /var/tmp/*

ENV WINEPREFIX=/var/lib/nokiaprefix
ENV WINEARCH=win32
ENV EPOCROOT=/var/lib/nokiaprefix/drive_c/Nokia/devices/Nokia_Symbian_Belle_SDK_v1.0
ENV PATH=/usr/local/bin:/usr/bin:/var/lib/nokiaprefix:/var/lib/nokiaprefix/drive_c/gcc-12.1.0/bin:/var/lib/nokiaprefix/drive_c/Nokia/devices/Nokia_Symbian_Belle_SDK_v1.0/epoc32/tools
