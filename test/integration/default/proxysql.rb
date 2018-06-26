# Inspec test for recipe proxysql::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('/etc/proxysql/proxysql-first.cnf') do
  it { should exist }
  its('owner') { should eq 'proxysql' }
end

describe directory('/var/lib/proxysql/proxysql-first') do
  it { should exist }
end

describe package('proxysql') do
  it { should be_installed }
end

# ProxySQL admin
describe port(6033) do
  it { should be_listening }
  its('protocols') { should include('tcp') }
end
