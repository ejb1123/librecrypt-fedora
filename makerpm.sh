rpmdev-setuptree
cp librevault.spec ~/rpmbuild/SPECS/
cp memory.patch librevault-v0.1.18.9.tar.gz ~/rpmbuild/SOURCES/
echo -e '%_topdir %(echo $HOME)/rpmbuild\n%__make /usr/bin/make -j 9' > ~/.rpmmacross
cd ~/rpmbuild/SPECS/
rpmbuild -ba librevault.spec

