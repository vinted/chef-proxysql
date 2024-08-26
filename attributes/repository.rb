default['proxysql']['repository']['name'] = 'percona-original-release.repo'
default['proxysql']['repository']['url'] = 'https://repo.percona.com/yum/percona-release-1.0-9.noarch.rpm'
default['proxysql']['package_release'] = "1.1.el#{node['platform_version'].to_i}"
