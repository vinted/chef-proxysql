name 'proxysql'
maintainer 'Ernestas Poskus'
maintainer_email 'ernestas.poskus@gmail.com'
license 'MIT'
description 'Installs/Configures ProxySQL'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url 'https://github.com/ernestas-poskus/chef-proxysql/issues'
source_url 'https://github.com/ernestas-poskus/chef-proxysql'
chef_version '>= 12.1' if respond_to?(:chef_version)
version '0.2.0'

supports 'centos'

depends 'poise', '~> 2.8.1'
