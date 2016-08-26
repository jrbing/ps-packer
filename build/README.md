# RPM Build Instructions

This directory contains the instructions and spec files for compiling and building the necessary rpm packages that are not available through the built-in repository or EPEL.

## Build Environment Setup

First (as root), run the following commands to install the prerequisites for creating the RPM's.

    yum groupinstall 'Development Tools'
    yum install rpm-build redhat-rpm-config
    yum install openssl-devel
    yum install boost
    yum install libxml2-devel

Next, add a non-root user for building the packages under.

    adduser builduser
    passwd builduser
    usermod -aG wheel builduser

## Build RPM's

Switch from root to the build user, create the necessary build directories, modify build settings, and cd into the build root.

    su - builduser
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
    cat <<EOF >~/.rpmmacros
    %_topdir   %(echo $HOME)/rpmbuild
    %_tmppath  %{_topdir}/tmp
    EOF
    cd ~/rpmbuild

Finally, copy the spec files into the SPECS directory and build each one.

    rpmbuild -ba SPECS/<spec_file_name>.spec

