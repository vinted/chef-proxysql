name 'proxysql'
maintainer 'Ernestas Poskus'
maintainer_email 'ernestas.poskus@gmail.com'
license 'MIT'
description 'Installs/Configures ProxySQL'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url 'https://github.com/ernestas-poskus/chef-proxysql/issues'
source_url 'https://github.com/ernestas-poskus/chef-proxysql'
chef_version '>= 12.1' if respond_to?(:chef_version)
version '2.2.1'

supports 'redhat'
supports 'centos'
supports 'ubuntu'
supports 'debian'

depends 'poise', '~> 2.8.1'
depends 'poise-service', '~> 1.5.2'
