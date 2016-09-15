FROM fedora:24
RUN yum update -y
RUN mkdir /opt/build-dir
VOLUME /opt/build-dir
ENTRYPOINT docker-build/makerpm.sh
