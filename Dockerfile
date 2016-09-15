FROM fedora:24
RUN yum install -y rpm-build rpmdevtools dnf-plugins-core
RUN mkdir /opt/build-dir
VOLUME /opt/build-dir
WORKDIR /opt/build-dir
COPY ./ ./
ENTRYPOINT docker-build/makerpm.sh
