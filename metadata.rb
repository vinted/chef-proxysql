name 'proxysql'
maintainer 'Vinted SRE'
maintainer_email 'sre@vinted.com'
license 'MIT'
description 'Installs/Configures ProxySQL'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url 'https://github.com/vinted/chef-proxysql/issues'
source_url 'https://github.com/vinted/chef-proxysql'
chef_version '>= 12.1' if respond_to?(:chef_version)
version '3.4.0'

supports 'redhat'
supports 'centos'
supports 'ubuntu'
supports 'debian'

depends 'poise', '~> 2.8.1'
depends 'systemd', '~> 3.2.3'
