DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
ls .
ls ..
ls /opt
ls /opt/buid-dir
rpmdev-setuptree
cp librevault.spec ~/rpmbuild/SPECS/
cp memory.patch librevault-v0.1.18.9.tar.gz ~/rpmbuild/SOURCES/
echo -e '%_topdir %(echo $HOME)/rpmbuild\n%__make /usr/bin/make -j 16' > ~/.rpmmacross
cd ~/rpmbuild/SPECS/
dnf copr enable -y ejb1123/protobuf
dnf builddep -y librevault.spec
rpmbuild -ba librevault.spec
cp -r ~/rpmbuild/RPMS /opt/build-dir
