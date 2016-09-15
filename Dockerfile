FROM fedora:24
RUN mkdir /opt/build-dir
VOLUME /opt/build-dir
WORKDIR /opt/build-dir
#ENTRYPOINT docker-build/makerpm.sh
ENTRYPOINT ls
