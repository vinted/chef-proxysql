name 'proxysql'
maintainer 'Vinted SRE'
maintainer_email 'sre@vinted.com'
license 'MIT'
description 'Installs/Configures ProxySQL'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
chef_version '>= 12.1' if respond_to?(:chef_version)
version '5.0.0'

depends 'poise', '~> 2.8.1'
depends 'systemd', '~> 3.2.3'

source_url 'https://github.com/vinted/chef-proxysql'
issues_url 'https://github.com/vinted/chef-proxysql/issues'

supports 'centos'
supports 'redhat'
supports 'rocky'
