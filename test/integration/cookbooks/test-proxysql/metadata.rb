name 'test-proxysql'
maintainer 'Ernestas Poskus'
maintainer_email 'ernestas.poskus@gmail.com'
license 'BSD 3-Clause License'
description 'Tests proxysql'
chef_version '>= 12.1' if respond_to?(:chef_version)
version '0.1.0'

depends 'proxysql'
depends 'mysql', '~> 8.5.1'
depends 'yum-mysql-community'
