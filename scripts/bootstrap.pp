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

apache::vhost { $::fqdn :
  docroot    => '/tmp',
  ssl        => true,
  ssl_cert   => '/etc/ssl/certs/puppetdb.pem',
  port       => '8081',
  proxy_pass => [
    {
      'path' => '/',
      'url'  => 'http://localhost:8080/'
    }
  ]
}
