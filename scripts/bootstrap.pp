Class['hiera'] -> Class['apache']

class { 'hiera' :
  datadir   => '/etc/puppet/data',
  hierarchy => [
    '%{::type}/%{::fqdn}',
    '%{::type}/common',
    'common',
  ]
}

class {'::apache' :
  purge_configs => false,
}
include 'apache::mod::wsgi'

apache::vhost { 'puppetdb' :
  docroot    => '/tmp',
  ssl        => true,
  ssl_cert   => '/etc/puppet/ssl/puppetdb.pem',
  ssl_key    => '/etc/puppet/ssl/puppetdb.pem',
  port       => '8081',
  servername => $::fqdn,
  proxy_pass => [
    {
      'path' => '/',
      'url'  => 'http://localhost:8080/'
    }
  ]
}
