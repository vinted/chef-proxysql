# Inspec test for recipe proxysql::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# ProxySQL
describe service('proxysql-2balance') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

# ProxySQL admin
describe port(6033) do
  it { should be_listening }
  its('protocols') { should include('tcp') }
end

sql = mysql_session('admin', 'admin', '127.0.0.1', 6032)
query = 'SELECT count(*) FROM monitor.mysql_server_ping_log WHERE ping_error IS NOT NULL;'

describe sql.query(query) do
  its('stderr') { should_not match(/Can't connect to local MySQL server through socket/) }
  its('stdout') { should match(/0$/) }
end
