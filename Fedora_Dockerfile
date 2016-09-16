FROM fedora:24
RUN dnf install -y gcc gcc-c++ rpm-build rpmdevtools dnf-plugins-core make cpp
RUN mkdir /opt/build-dir
VOLUME /opt/build-dir
WORKDIR /opt/build-dir
#COPY ./ ./
ENTRYPOINT docker-build/makerpm.sh
