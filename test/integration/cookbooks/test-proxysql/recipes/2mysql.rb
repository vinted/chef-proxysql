include_recipe 'test-proxysql::setup'

pass = 'suchsecret'

first_port = 3300
second_port = 3301

execute 'create_user_for_first' do
  # rubocop:disable Metrics/LineLength
  command %(echo "GRANT ALL PRIVILEGES ON *.* TO 'monitor'@'%' IDENTIFIED BY 'monitor';" | mysql -u root -p#{pass} -h 127.0.0.1 -P #{first_port})
  action :nothing
end

execute 'create_user_for_second' do
  # rubocop:disable Metrics/LineLength
  command %(echo "GRANT ALL PRIVILEGES ON *.* TO 'monitor'@'%' IDENTIFIED BY 'monitor';" | mysql -u root -p#{pass} -h 127.0.0.1 -P #{second_port})
  action :nothing
end

mysql_service 'first' do
  port first_port
  initial_root_password pass
  version '5.6'
  action %i[create start]
end

mysql_service 'second' do
  port second_port
  initial_root_password pass
  version '5.6'
  action %i[create start]
end

servers = {
  '2mysql' => [
    {
      address: '127.0.0.1',
      'port' => first_port,
      hostgroup: 1,
      'max_connections' => 200
    },
    {
      'address' => '127.0.0.1',
      'port' => second_port,
      'hostgroup' => 1
    }
  ]
}

users = {
  '2mysql' => [
    {
      username: 'root',
      password: pass,
      default_hostgroup: 2,
      'active' => 1
    }
  ]
}

admin_variables = {
  admin_credentials: 'admin:admin',
  'mysql_ifaces' => '127.0.0.1:6032'
}

variables = {
  'monitor_username' => 'monitor',
  monitor_password: 'monitor'
}

proxysql_service '2balance' do
  admin_variables admin_variables
  mysql_servers servers
  mysql_users users
  mysql_variables variables
  notifies :run, 'execute[create_user_for_first]', :immediately
  notifies :run, 'execute[create_user_for_second]', :immediately
end
