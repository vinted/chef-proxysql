name 'test-proxysql'
maintainer 'Vinted SRE'
maintainer_email 'sre@vinted.com'
license 'MIT'
description 'Tests proxysql'
chef_version '>= 12.1' if respond_to?(:chef_version)
version '0.1.0'

depends 'mysql'
depends 'proxysql'

source_url 'https://github.com/vinted/chef-proxysql'
issues_url 'https://github.com/vinted/chef-proxysql/issues'
