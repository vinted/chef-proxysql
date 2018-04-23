default['proxysql']['version'] = '1.4.7'

# Meant for easier contributing to this cookbook
default['proxysql']['lock_version'] = true

default['proxysql']['user'] = 'proxysql'
default['proxysql']['group'] = 'proxysql'

default['proxysql']['config_dir'] = '/etc/proxysql'
default['proxysql']['data_dir'] = '/var/lib/proxysql'

default['proxysql']['service']['flags'] = {
  'exit-on-error' => false,
  'no-monitor' => false,
  'no-start' => false,
  'reuseport' => true,
  'idle-threads' => true,
  'initial' => false,
  'reload' => false,
  'sqlite3-server' => false
}

default['proxysql']['config']['admin_variables'] = {}
default['proxysql']['config']['mysql_variables'] = {}

# Special node attributes must be in a form of:
# {
#   "string": [objects]
# }
# Hash key "string" must be of type String it is necessary for support
# of multiple attributes, hash values then are merged into 1 and
# gets casted to CNF.
default['proxysql']['config']['mysql_servers'] = {}
default['proxysql']['config']['mysql_users'] = {}
default['proxysql']['config']['mysql_query_rules'] = {}
default['proxysql']['config']['schedulers'] = {}
default['proxysql']['config']['mysql_replication_hostgroups'] = {}
