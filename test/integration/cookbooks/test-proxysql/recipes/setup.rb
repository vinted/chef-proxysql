execute 'dnf module disable mysql -y' if node['platform_version'].to_i >= 8

yum_repository 'mysql57-community' do
  description 'MySQL 5.7 Community Server'
  baseurl 'http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/'
  enabled true
  gpgcheck true
  gpgkey 'https://repo.mysql.com/RPM-GPG-KEY-mysql-2022'
end
