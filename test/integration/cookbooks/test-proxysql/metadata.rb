name 'test-proxysql'
maintainer 'Vinted SRE'
maintainer_email 'sre@vinted.com'
license 'MIT'
description 'Tests proxysql'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/vinted/chef-proxysql/issues'
source_url 'https://github.com/vinted/chef-proxysql'
version '0.1.0'

depends 'proxysql'
depends 'mysql', '~> 8.5.1'
depends 'yum-mysql-community'
