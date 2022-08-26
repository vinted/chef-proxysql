# ProxySQL admin
describe port(6033) do
  it { should be_listening }
  its('protocols') { should include('tcp') }
end

query = 'SELECT count(*) FROM monitor.mysql_server_ping_log WHERE ping_error IS NOT NULL;'
cmd = "mysql -h 127.0.0.1 -P 6032 -u admin -padmin --execute=\"#{query}\""

describe command(cmd) do
  its('stderr') { should_not match(/Can't connect to local MySQL server through socket/) }
  its('stdout') { should match(/0$/) }
end
