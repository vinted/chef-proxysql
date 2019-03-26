default['percona']['repository']['name'] = 'percona-original-release.repo'

case node['platform']
when 'rhel', 'centos'
  default['percona']['repository']['url'] = 'http://repo.percona.com/yum/percona-release-latest.noarch.rpm'
when 'debian', 'ubuntu'
  lsb_release = Mixlib::ShellOut.new('lsb_release -sc')
  lsb_release.run_command
  lsb_release.error!
  lsb_release = lsb_release.stdout.chomp

  default['percona']['repository']['url'] = "http://repo.percona.com/apt/percona-release_latest.#{lsb_release}_all.deb"
end
