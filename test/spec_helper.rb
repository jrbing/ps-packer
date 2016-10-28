require 'serverspec'
require 'net/ssh'

set :backend, :ssh

set :path, '/usr/local/sbin:/usr/sbin:/sbin:$PATH'
