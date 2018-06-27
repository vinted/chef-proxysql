# ProxySQL
describe service('proxysql-2balance') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/proxysql/proxysql-2balance.cnf') do
  it { should exist }
  its('content') { should match 'admin_credentials="admin:admin;cluster1:otherpass"' }
end
