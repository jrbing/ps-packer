Summary: Download utility with BitTorrent and Metalink support
Name: aria2
Version: 1.26.0
Release: 1%{?dist}
License: GPL
Group: Applications/Internet
URL: https://aria2.github.io/

Source: https://github.com/aria2/aria2/releases/download/release-%{version}/aria2-%{version}.tar.bz2
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: boost >= 1.53
BuildRequires: gcc-c++
BuildRequires: gettext
BuildRequires: libxml2-devel
BuildRequires: openssl-devel >= 1.0.1
BuildRequires: pkgconfig

%description
aria2 is a download utility with resuming and segmented downloading.
Supported protocols are HTTP/HTTPS/FTP/BitTorrent/Metalink.

%prep
%setup

%build
%{expand: %%define optflags %{optflags} %(pkg-config --cflags openssl)}
%configure \
    ARIA2_STATIC=yes \
    --disable-xmltest \
    --enable-metalink
%{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR="%{buildroot}"
%find_lang aria2

%{__mv} -v %{buildroot}%{_docdir}/aria2 _rpmdocs

%clean
%{__rm} -rf %{buildroot}

%files -f aria2.lang
%defattr(-, root, root, 0755)
%doc ChangeLog COPYING NEWS AUTHORS _rpmdocs/*
%doc %{_mandir}/man1/aria2c.1*
%doc %{_mandir}/*/man1/aria2c.1*
%{_bindir}/aria2c

