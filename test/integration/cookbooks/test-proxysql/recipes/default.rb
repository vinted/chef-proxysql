include_recipe 'test-proxysql::setup'
package 'mysql'

proxysql_service 'first' do
end

proxysql_admin_config 'first' do
end
