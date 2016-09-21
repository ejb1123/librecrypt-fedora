DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..
export VERSION=$(echo $(git describe) | cut -d'v' -f 2)
echo $VERSION
cd $DIR
rpmdev-setuptree
ls .
ls ..
ls ../..
tar -czvf librevault-v$VERSION.tar.gz $DIR/../../librevault
cp librevault.spec ~/rpmbuild/SPECS/
cp memory.patch librevault-v$VERSION.tar.gz ~/rpmbuild/SOURCES/
echo -e "%_topdir %(echo $HOME)/rpmbuild\n%__make /usr/bin/make -j$(echo "$(nproc) + $(nproc)/2" | bc)" > ~/.rpmmacros
cd ~/rpmbuild/SPECS/
dnf copr enable -y ejb1123/protobuf
dnf builddep -y librevault.spec
rpmbuild -ba --define="VERSION $VERSION" librevault.spec
cp -r ~/rpmbuild/RPMS /opt/build-dir/librevault
cp -r ~/rpmbuild/SRPMS /opt/build-dir/librevault
