DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..
$version=$(git describe)
export version=$(git describe)
cd $DIR
rpmdev-setuptree
tar -czvf librevault-$version.tar.gz $DIR/../../librevault
cp librevault.spec ~/rpmbuild/SPECS/
cp memory.patch librevault-$version.tar.gz ~/rpmbuild/SOURCES/
echo -e "%_topdir %(echo $HOME)/rpmbuild\n%__make /usr/bin/make -j$(echo "$(nproc) + $(nproc)/2" | bc)" > ~/.rpmmacros
cd ~/rpmbuild/SPECS/
dnf copr enable -y ejb1123/protobuf
dnf builddep -y librevault.spec
rpmbuild -ba librevault.spec
cp -r ~/rpmbuild/RPMS /opt/build-dir
cp -r ~/rpmbuild/SRPMS /opt/build-dir
