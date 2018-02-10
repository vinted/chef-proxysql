default['percona']['repository']['name'] = 'percona-release.repo'
default['percona']['repository']['version'] = '0.1-4'

case node['platform']
when 'rhel', 'centos'
  platform_version = node['platform_version'].to_i
  version = node['proxysql']['version']
  default['proxysql']['package_version'] = "#{version}-1.1.el#{platform_version}"

  default['percona']['repository']['url'] = 'http://www.percona.com/'\
    'downloads/percona-release/redhat/'\
    "#{node['percona']['repository']['version']}/"\
    "percona-release-#{node['percona']['repository']['version']}.noarch.rpm"
when 'debian', 'ubuntu'
  lsb_release = Mixlib::ShellOut.new('lsb_release -sc')
  lsb_release.run_command
  lsb_release.error!
  lsb_release = lsb_release.stdout.chomp

  default['proxysql']['package_version'] = "#{node['proxysql']['version']}-1.1.#{lsb_release}"

  default['percona']['repository']['url'] =
    'http://repo.percona.com/apt/percona-release_'\
    "#{node['percona']['repository']['version']}."\
    "#{lsb_release}_all.deb"
end
