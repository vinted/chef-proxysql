include_recipe 'test-proxysql::setup'

package 'mysql-community-server' do
  flush_cache [:before]
end

proxysql_service 'first' do
  service_name 'proxysql-first'
end

proxysql_admin_config 'first' do
end
