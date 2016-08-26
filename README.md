# ps-packer #

Packer templates and scripts for building Vagrant boxes to be used with [ps-vagabond][ps-vagabond]

## Prerequisities ##

* [Packer][packer]
* [VirtualBox][virtualbox]

## Usage ##

Simply run `packer build vagabond_ol72.json` from the current directory.

## TODO ##

* Add additional builders
    * Azure
    * VMWare
    * QEMU
* Add tests (using http://kitchen.ci/)

[packer]:https://www.packer.io "http://www.packer.io"
[virtualbox]:https://www.virtualbox.org "http://www.virtualbox.org"
[boxcutter]:https://github.com/boxcutter/centos "https://github.com/boxcutter/centos"
[ps-vagabond]:https://github.com/jrbing/ps-vagabond "https://github.com/jrbing/ps-vagabond".

Copyright © 2016 JR Bing

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
