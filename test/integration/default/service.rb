# ProxySQL
describe service('proxysql-first') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/systemd/system/proxysql-first.service') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('content') { should match 'TimeoutSec = 5' }
  its('content') { should match 'Restart = on-failure' }
  its('content') { should match 'User = proxysql' }
  its('content') { should match 'Group = proxysql' }
  its('content') { should match 'LimitCORE = 1073741824' }
  its('content') { should match 'LimitNOFILE = 102400' }
end
