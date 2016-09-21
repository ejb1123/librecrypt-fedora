Name:		librevault
Version:	0.1.18.11
Release:	1%{?dist}
Summary:	Peer-to-peer, decentralized and open source file sync

License:	GPL3
URL:		https://github.com/Librevault/librevault
Source0:	librevault-v%{version}.tar.gz

BuildRequires:	cmake
BuildRequires:	git
BuildRequires:	gcc
BuildRequires:	boost-devel
BuildRequires:	openssl-devel
BuildRequires:	cryptopp-devel
BuildRequires:	qt5-qtbase-devel
BuildRequires:	qt5-qtsvg-devel
BuildRequires:	qt5-qtwebsockets-devel
BuildRequires:	qt5-linguist
BuildRequires:	sqlite-devel
BuildRequires:	icu
BuildRequires:	protobuf-devel

%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

%description
Librevault is an open-source peer-to-peer file synchronization program, designed with convenience and privacy in mind. Our goal is to make a better alternative to BitTorrent Sync and Syncthing.

%prep

%setup -n %{name}
mkdir build
cd build

CC=gcc CXX=g++ cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS=-std=c99 \
    -DCMAKE_CXX_FLAGS=-std=c++14\
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DWITH_TESTS=OFF \
	-DWITH_EXAMPLE=OFF ..

%build
cd build
CC=gcc CXX=g++ cmake --build . -- -j $(nproc)

%install
rm -rf %{buildroot}
cd build
make DESTDIR="%{buildroot}" install

%files
%{_bindir}/*
%{_datadir}/applications/Librevault.desktop
%{_datadir}/icons/hicolor/scalable/apps/librevault.svg
#%if (0%{?suse_version} == 1315 && 0%{?sle_version} == 120100) || (0%{?suse_version} == 1315 && 0%{?sle_version} == 120100)
%{_datarootdir}/icons/*
#%endif

%doc

%changelog
* Thu Sep 08 2016 Philip Klostermann <philip.klostermann@gmail.com> - 0.1.15-1
- Initial RPM build


