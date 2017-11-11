describe file('/etc/proxysql/first-admin.cnf') do
  it { should exist }
  its('owner') { should eq 'proxysql' }
end
