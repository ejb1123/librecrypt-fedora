DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
rpmdev-setuptree
tar -czvf librevault-v0.1.18.11.tar.gz $DIR/../../librevault
cp librevault.spec ~/rpmbuild/SPECS/
cp memory.patch librevault-v0.1.18.11.tar.gz ~/rpmbuild/SOURCES/
echo -e "%_topdir %(echo $HOME)/rpmbuild\n%__make /usr/bin/make -j$(echo "$(nproc) + $(nproc)/2" | bc)" > ~/.rpmmacros
cd ~/rpmbuild/SPECS/
dnf copr enable -y ejb1123/protobuf
dnf builddep -y librevault.spec
rpmbuild -ba librevault.spec
cp -r ~/rpmbuild/RPMS /opt/build-dir
cp -r ~/rpmbuild/SRPMS /opt/build-dir
