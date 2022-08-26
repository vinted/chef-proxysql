default['proxysql']['repository']['name'] = 'percona-original-release.repo'
default['proxysql']['repository']['url'] = 'http://repo.percona.com/yum/percona-release-latest.noarch.rpm'
default['proxysql']['package_release'] = "1.1.el#{node['platform_version'].to_i}"
