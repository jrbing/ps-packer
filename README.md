ps-packer
=========

Packer templates and provisioning scripts for building Vagrant boxes to be used with [ps-vagabond][vagabond].  Largely based on work done by the [Boxcutter Project][boxcutter].

## Prerequisities ##

* [Packer][packer]
* [VirtualBox][virtualbox]

## Usage ##

Simply run `packer build vagabond_ol72.json` from the current directory.

## TODO ##

* Additional builders
    * VMWare
    * QEMU
* Tests (using http://kitchen.ci/)

[packer]:https://www.packer.io "http://www.packer.io"
[virtualbox]:https://www.virtualbox.org "http://www.virtualbox.org"
[boxcutter]:https://github.com/boxcutter "https://github.com/boxcutter"
[vagabond]:https://github.com/jrbing/ps-vagabond "https://github.com/jrbing/ps-vagabond".
