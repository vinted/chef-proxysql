# frozen_string_literal: true

source 'https://supermarket.chef.io'

metadata

cookbook 'poise', '~> 2.8.1'
cookbook 'systemd', '~> 3.2.3'

group 'test' do
  cookbook 'test-proxysql', path: 'test/integration/cookbooks/test-proxysql'
end
