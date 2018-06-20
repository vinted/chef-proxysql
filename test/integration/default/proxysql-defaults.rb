%w[
  /etc/proxysql.cnf
  /etc/proxysql-admin.cnf
  /etc/init.d/proxysql
  /lib/systemd/system/proxysql.service
].each do |f|
  describe file(f) do
    it { should_not exist }
  end
end

describe service('proxysql') do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end
