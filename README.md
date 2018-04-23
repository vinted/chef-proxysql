# ProxySQL Chef cookbook

ProxySQL is a high performance, high availability, protocol aware proxy
for MySQL and forks (like Percona Server and MariaDB).

> Note: due to rapid ProxySQL development, locked ProxySQL version may not be available, therefore one might need to bump version `node['proxysql']['version']`.

[![Build Status](https://travis-ci.org/ernestas-poskus/chef-proxysql.svg?branch=master)](https://travis-ci.org/ernestas-poskus/chef-proxysql)
[![Cookbook Version](https://img.shields.io/cookbook/v/proxysql.svg)](https://supermarket.chef.io/cookbooks/proxysql)

Cookbook configures any number of ProxySQL instances, each instance has
isolated configuration. ProxySQL instance is installed through Chef
resource `protocol_service`.

Instances are configured through node['proxysql'] attributes and/or
`proxysql_*` block arguments. See the examples below.

Each ProxySQL is automatically managed by Chef, on disk configuration
changes are propagated to instance admin and are loaded to runtime.
Cookbook propagates these SQL statements to load configuration.

```sql
LOAD MYSQL USERS FROM CONFIG
LOAD MYSQL USERS TO RUNTIME
LOAD MYSQL SERVERS FROM CONFIG
LOAD MYSQL SERVERS TO RUNTIME
LOAD MYSQL QUERY RULES FROM CONFIG
LOAD MYSQL QUERY RULES TO RUNTIME
LOAD MYSQL VARIABLES FROM CONFIG
LOAD MYSQL VARIABLES TO RUNTIME
LOAD ADMIN VARIABLES FROM DISK
LOAD ADMIN VARIABLES TO RUNTIME
```

## Design

There are 5 special `proxysql_service` resource attributes.

```
# mysql_servers Hash
# mysql_users Hash
# mysql_query_rules Hash
# schedulers Hash
# mysql_replication_hostgroups Hash
```

Each attribute must be of type Hash (validated) and
associated key value must be Array (validated).
This structure allows merging node,role,data_bag overrides into
single one.

For example given.:

```json
{
  "name": "datacenter1",
  "override_attributes": {
    "proxysql": {
      "config": {
        "mysql_servers": {
          "dc1": [
            { "address": "/var/lib/mysql/mysql.sock", "hostgroup": 1 }
          ]
        }
      }
    }
  }
}
```

```json
{
  "name": "datacenter2",
  "override_attributes": {
    "proxysql": {
      "config": {
        "mysql_servers": {
          "dc2": [
            { "address": "127.0.0.1", "port": 21892 , "hostgroup": 1 }
          ]
        }
      }
    }
  }
}
```

These two roles `datacenter1` and `datacenter2` attributes will be merged
so the final `CNF` configuration will be.

```cnf
mysql_servers=(
{
  address="/var/lib/mysql/mysql.sock"
  hostgroup=1
},
{
  address="127.0.0.1"
  port=21892
  hostgroup=1
}
)
```

## Installation

Cookbook assumes `monitor` user is created on each database server.

Include this line in metadata.rb

```ruby
depends 'proxysql'
```

There are 2 ways to use this cookbook resources.

1. Include default recipe and manipulate node['proxysql'] attributes.

```ruby
include_recipe 'proxysql::default'
```

2. Use resource in any recipe.

```ruby
proxysql_service 'default' do
  # ...
end
```

## Requirements

 - Systemd
 - MySQL client (for loading configuration from disk to proxysql)

## Resources

```ruby
proxysql_service 'any name' do
  # service_name 'proxysql-eu1'
  # user String
  # group String
  # data_dir String
  # config_dir String
  # version String
  # bin String
  # admin_socket [String, NilClass]
  # flags Hash
  # admin_variables Hash
  # mysql_variables Hash
  # mysql_servers Hash
  # mysql_users Hash
  # mysql_query_rules Hash
  # schedulers Hash
  # mysql_replication_hostgroups Hash
  # service_name String
  # service_unit_after Array
  # service_install_wanted_by Array
  # service_restart String
  # service_restart_sec Integer
end
```

```ruby
proxysql_admin_config 'eu1' do
  # user String
  # group String
  # data_dir String
  # config_dir String
  # admin_username String
  # admin_password String
  # admin_hostname String
  # admin_port Integer
  # cluster_username String
  # cluster_password String
  # cluster_hostname String
  # cluster_port Integer
  # monitor_username String
  # monitor_password String
  # application_username String
  # application_password String
  # read_hostgroup_id String
  # write_hostgroup_id String
  # read_write_mode String
end
```

## Attributes

```ruby
default['proxysql']['version'] = '1.4.7'

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
```

## Examples

```ruby
pass = 'suchsecret'
first_port = 3300
second_port = 3301

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
  'monitor_password' => 'monitor'
}

proxysql_service '2balance' do
  service_name 'proxysql-2balance'
  admin_variables admin_variables
  mysql_servers servers
  mysql_users users
  mysql_variables variables
end
```

## License

BSD 3-Clause License

Copyright (c) 2017, Ernestas Poskus
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Author Information
------------------

 - Blog: [http://out13.com/](http://out13.com/)
 - Twitter: @ernestas_poskus
