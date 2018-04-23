include_recipe 'test-proxysql::setup'
case node['platform']
when 'rhel', 'centos'
  package 'mysql'
when 'debian', 'ubuntu'
  package 'mysql-server-5.6'
end

proxysql_service 'first' do
  service_name 'proxysql-first'
end

proxysql_admin_config 'first' do
end
