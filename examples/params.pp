#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Parameter examples
#
# Note: Hiera support is in progress by our team.
#

class os_params {

  # General parameters
  $compute                  = true
  $debug                    = true
  $install_packages         = false
  $release                  = 'havana'
  $region                   = 'enovance'
  $swift                    = true
  $verbose                  = false
  $compute_has_ceph         = true
  $use_syslog               = true
  $log_facility             = 'LOG_LOCAL0'
  $veth_mtu                 = '1500'
  $ntp_servers              = [
    '0.debian.pool.ntp.org',
    '1.debian.pool.ntp.org',
    '2.debian.pool.ntp.org',
    '3.debian.pool.ntp.org'
  ]

  # Architecture
  $site_domain        = 'lab.enovance.com'
  $dns_ips            = ['192.168.134.1']
  $smtp_name          = 'mxi1'

  $mgmt_names         = ['controller1','controller2','controller3']
  $mgmt_internal_ips  = ['192.168.134.45', '192.168.134.46', '192.168.134.47']

  $vip_public_ip      = '192.168.134.253'
  $vip_admin_ip       = $vip_public_ip
  $vip_internal_ip    = $vip_public_ip

  $vip_public_fqdn    = "vip-openstack.${site_domain}"
  $vip_admin_fqdn     = $vip_public_fqdn
  $vip_internal_fqdn  = $vip_public_fqdn

  $public_network     = '192.168.134.0/24'
  $admin_network      = $public_network
  $internal_network   = $public_network
  $storage_network    = $public_network

  $db_allowed_hosts   = ['controller%', '192.168.134.%']

  $public_netif       = 'eth0'
  $internal_netif     = $public_netif
  $admin_netif        = $public_netif
  $storage_netif      = $public_netif

  $lb_public_netif    = $public_netif
  $lb_internal_netif  = $internal_netif

  $swift_zone         = {
    'swiftstore1' => 1,
    'swiftstore2' => 2,
    'swiftstore3' => 3
  }

  $galera_master_name  = $mgmt_names[0]
  $galera_internal_ips = $mgmt_internal_ips
  $galera_ip           = $vip_internal_ip

  $galera_nextserver  = {
    "${galera_master_name}" => $mgmt_internal_ips[0],
    "${mgmt_names[1]}"      => $mgmt_internal_ips[1],
    "${mgmt_names[2]}"      => $mgmt_internal_ips[2]
  }

  $ceph_version       = 'cuttlefish'

  $ceph_names         = ['cephstore1','cephstore2','cephstore3']

  $ceph_osd_devices   = ['sdb','sdc','sdd']

  # Hypervisor
  $libvirt_type       = 'kvm'

  $public_cidr        = '172.24.4.224/28'

  $args = get_scope_args()
  $schema = {
    'type' => 'map',
    'mapping' => {
      'ntp_servers' => {
        'type'      => 'any',
        'required'  => true,
      },
      'compute' => {
        'type'     => 'bool',
        'required' => true,
      },
      'debug' => {
        'type'     => 'bool',
        'required' => true,
      },
      'use_syslog' => {
        'type'     => 'bool',
        'required' => true,
      },
      'log_facility' => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'install_packages' => {
        'type'     => 'bool',
        'required' => true,
      },
      'release' => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'region' => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'swift' => {
        'type'     => 'bool',
        'required' => true,
      },
      'verbose' => {
        'type'     => 'bool',
        'required' => true,
      },
      'compute_has_ceph' => {
        'type'     => 'bool',
        'required' => true,
      },
      'dns_ips' => {
        'type'     => 'any',
        'required' => true,
      },
      'smtp_name'   => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'site_domain' => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'mgmt_names'  => {
        'type'     => 'any',
        'required' => true,
      },
      'mgmt_internal_ips'  => {
        'type'     => 'any',
        'required' => true,
      },
      'vip_public_ip'    => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'vip_admin_ip'     => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'vip_internal_ip'  => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'vip_public_fqdn'    => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'vip_admin_fqdn'     => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'vip_internal_fqdn'  => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'public_network'     => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'storage_network'     => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'admin_network'      => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'internal_network'   => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'db_allowed_hosts'  => {
        'type'     => 'any',
        'required' => true,
      },
      'public_netif'      => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'internal_netif'    => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'admin_netif'       => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'storage_netif'     => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'lb_public_netif'   => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'lb_internal_netif' => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'swift_zone' => {
        'type'     => 'any',
        'required' => true,
      },
      'galera_master_name'   => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'galera_ip'            => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'galera_internal_ips' => {
        'type'     => 'any',
        'required' => true,
      },
      'galera_nextserver' => {
        'type'     => 'any',
        'required' => true,
      },
      'ceph_names' => {
        'type'     => 'any',
        'required' => true,
      },
      'ceph_version' => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'ceph_osd_devices' => {
        'type'     => 'any',
        'required' => true,
      },
      'libvirt_type' => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      },
      'veth_mtu'  => {
        'type'     => 'str',
        'pattern'  => '/^\d+$/',
        'required' => true,
      },
      'public_cidr' => {
        'type'     => 'str',
        'pattern'  => '/^.+$/',
        'required' => true,
      }
    }
  }

  kwalify($schema, $args)

  $internal_netif_ip = getvar("::ipaddress_${internal_netif}")
  $admin_netif_ip    = getvar("::ipaddress_${admin_netif}")
  $public_netif_ip   = getvar("::ipaddress_${public_netif}")

  $storage_netif_ip  = getvar("::ipaddress_${storage_netif}")
  $lb_public_netif_ip = getvar("::ipaddress_${lb_public_netif}")
  $lb_internal_netif_ip = getvar("::ipaddress_${lb_internal_netif}")

  # Root hashed password. Non-hashed: "enovance"
  $root_password = '$1$2X/chMfy$CuJ4xPZY0WO2pRfIm5djn/'

  # Hardware
  $api_eth = $internal_netif_ip
  $storage_eth = $storage_netif_ip

  # Red Hat Network registration
  $rhn_registration = {
      username    => 'rhn',
      password    => 'pass',
      server_url  => 'https://rhn.redhat.com/rpc/api',
      force       => true
  }

  # OpenStack Identity
  $identity_roles_addons = ['SwiftOperator', 'ResellerAdmin']
  $keystone_db_allowed_hosts = $db_allowed_hosts
  $keystone_db_host = $galera_ip
  $keystone_db_password = 'secrete'
  $keystone_db_user = 'keystone'
  $ks_admin_email = 'dev@enovance.com'
  $ks_admin_password = 'secrete'
  $ks_admin_tenant = 'admin'
  $ks_admin_token = 'secrete'
  $ks_keystone_internal_host = $vip_internal_fqdn
  $ks_keystone_internal_port = '5000'
  $ks_keystone_internal_proto = 'http'
  $ks_keystone_admin_host = $vip_admin_fqdn
  $ks_keystone_admin_port = '35357'
  $ks_keystone_admin_proto = 'http'
  $ks_keystone_public_host = $vip_public_fqdn
  $ks_keystone_public_port = '5000'
  $ks_keystone_public_proto = 'http'
  $ks_token_expiration = '3600'

  # Swift
  $ks_swift_internal_proto = 'http'
  $ks_swift_admin_host = $vip_admin_fqdn
  $ks_swift_admin_port = '8080'
  $ks_swift_admin_proto = 'http'
  $ks_swift_dispersion_password = 'secrete'
  $ks_swift_internal_host = $vip_internal_fqdn
  $ks_swift_internal_port = '8080'
  $ks_swift_password = 'secrete'
  $ks_swift_public_host = $vip_public_fqdn
  $ks_swift_public_port = '8080'
  $ks_swift_public_proto = 'http'
  $replicas = '3'
  $statsd_host = '127.0.0.1'
  $statsd_port = '4125'
  $swift_cors_allow_origin = "http://${vip_internal_fqdn}"
  $swift_hash_suffix = 'secrete'
  $swift_port = '8080'
  $swift_rsync_max_connections = '5'

  # MySQL
  $mysql_root_password = 'secrete'
  $mysql_sys_maint_user = 'sys-maint'
  $mysql_sys_maint_password = 'secrete'
  $galera_clustercheck_dbuser = 'clustercheckuser'
  $galera_clustercheck_dbpassword = 'clustercheckpassword!'

  # Memcached
  $memcache_servers = suffix($mgmt_internal_ips, ':11211')

  # Corosync
  $cluster_ip = $internal_netif_ip

  # LoadBalancer
  $keepalived_interface = $lb_public_netif
  $keepalived_email = ["dev@${site_domain}"]
  $keepalived_smtp = "${smtp_name}.${site_domain}"
  $keepalived_localhost_ip = $lb_internal_netif_ip
  $haproxy_auth = 'root:secrete'

  # Horizon
  $horizon_port = '80'
  $secret_key = 'secrete'

  # RabbitMQ
  #FIXME: https://github.com/enovance/puppet-openstack-cloud/issues/14
  $rabbit_names = $mgmt_names
  $rabbit_host = $mgmt_internal_ips[0]
  $rabbit_hosts = suffix($mgmt_internal_ips,':5672')
  $rabbit_password = 'secrete'
  # Useful when we need a single Rabbit host (like Sensu needs)
  $rabbit_main_host = $mgmt_internal_ips[0]

  # Neutron
  $external_int = $public_netif
  $ks_neutron_admin_host = $vip_admin_fqdn
  $ks_neutron_admin_port = '9696'
  $ks_neutron_admin_proto = 'http'
  $ks_neutron_internal_host = $vip_internal_fqdn
  $ks_neutron_internal_port = '9696'
  $ks_neutron_internal_proto = 'http'
  $ks_neutron_password = 'secrete'
  $ks_neutron_public_host = $vip_public_fqdn
  $ks_neutron_public_port = '9696'
  $ks_neutron_public_proto = 'http'
  $neutron_db_allowed_hosts = $db_allowed_hosts
  $neutron_db_host = $galera_ip
  $neutron_db_password = 'secrete'
  $neutron_db_user = 'neutron'
  $neutron_port = '9696'
  $tunnel_eth = $internal_netif_ip
  $provider_vlan_ranges = ['physnet1:1000:2999']
  $provider_bridge_mappings = ['physnet1:br-eth1']
  $dnsmasq_dns_servers = '8.8.8.8,8.8.4.4'

  # Nova
  $ks_nova_password = 'secrete'
  $nova_db_allowed_hosts = $db_allowed_hosts
  $nova_db_host = $galera_ip
  $nova_db_password = 'secrete'
  $nova_db_user = 'nova'
  $nova_port = '8774'
  $ks_nova_admin_host = $vip_admin_fqdn
  $ks_nova_admin_port = '8774'
  $ks_nova_admin_proto = 'http'
  $ks_nova_internal_host = $vip_internal_fqdn
  $ks_nova_internal_port = '8774'
  $ks_nova_internal_proto = 'http'
  $ks_nova_public_host = $vip_public_fqdn
  $ks_nova_public_port = '8774'
  $ks_ec2_public_port = '8773'
  $ks_metadata_public_port = '8775'
  $ks_nova_public_proto = 'http'
  $neutron_metadata_proxy_shared_secret = 'secrete'
  $spice_port = '6082'
  $nova_rbd_user = 'nova'
  $nova_rbd_pool = 'vm'
  $nova_ssh_public_key = 'ssh-rsa XXX nova@openstack'
  $nova_ssh_private_key = '
-----BEGIN RSA PRIVATE KEY-----
XXX
-----END RSA PRIVATE KEY-----
'

  # Glance
  $glance_db_allowed_hosts = $db_allowed_hosts
  $glance_db_host = $galera_ip
  $glance_db_password = 'secrete'
  $glance_db_user = 'glance'
  $glance_rbd_user = 'glance'
  $glance_rbd_pool = 'images'
  $ks_glance_admin_host = $vip_admin_fqdn
  $ks_glance_api_admin_port = '9292'
  $ks_glance_admin_proto = 'http'
  $ks_glance_internal_host = $vip_internal_fqdn
  $ks_glance_api_internal_port = '9292'
  $ks_glance_registry_internal_port = '9191'
  $ks_glance_internal_proto = 'http'
  $ks_glance_public_host = $vip_public_fqdn
  $ks_glance_api_public_port = '9292'
  $ks_glance_public_proto = 'http'
  $ks_glance_password = 'secrete'

  # Ceilometer
  $ceilometer_secret = 'secrete'
  $ks_ceilometer_admin_host = $vip_admin_fqdn
  $ks_ceilometer_admin_port = '8777'
  $ks_ceilometer_admin_proto = 'http'
  $ks_ceilometer_internal_host = $vip_internal_fqdn
  $ks_ceilometer_internal_port = '8777'
  $ks_ceilometer_internal_proto = 'http'
  $ks_ceilometer_password = 'secrete'
  $ks_ceilometer_public_host = $vip_public_fqdn
  $ks_ceilometer_public_port = '8777'
  $ks_ceilometer_public_proto = 'http'
  $replset_members = $mgmt_internal_ips
  $mongo_nodes = $mgmt_internal_ips

  # Cinder
  $cinder_db_allowed_hosts = $db_allowed_hosts
  $cinder_db_host = $galera_ip
  $cinder_db_password = 'secrete'
  $cinder_db_user = 'cinder'
  $cinder_rbd_user = 'cinder'
  $cinder_rbd_pool = 'volumes'
  $cinder_rbd_backup_user = 'cinder'
  $cinder_rbd_backup_pool = 'cinder_backup'
  $glance_api_version = '2'
  $ks_cinder_admin_host = $vip_admin_fqdn
  $ks_cinder_admin_port = '8776'
  $ks_cinder_admin_proto = 'http'
  $ks_cinder_internal_host = $vip_internal_fqdn
  $ks_cinder_internal_port = '8776'
  $ks_cinder_internal_proto = 'http'
  $ks_cinder_password = 'secrete'
  $ks_cinder_public_host = $vip_public_fqdn
  $ks_cinder_public_port = '8776'
  $ks_cinder_public_proto = 'http'

  # Heat
  $heat_db_allowed_hosts = $db_allowed_hosts
  $heat_db_host = $galera_ip
  $heat_db_password = 'secrete'
  $heat_db_user = 'heat'
  $ks_heat_admin_host = $vip_admin_fqdn
  $ks_heat_admin_port = '8004'
  $ks_heat_cfn_admin_port = '8000'
  $ks_heat_cloudwatch_admin_port = '8003'
  $ks_heat_admin_proto = 'http'
  $ks_heat_internal_host = $vip_internal_fqdn
  $ks_heat_internal_port = '8004'
  $ks_heat_cfn_internal_port = '8000'
  $ks_heat_cloudwatch_internal_port = '8003'
  $ks_heat_internal_proto = 'http'
  $ks_heat_password = 'secrete'
  $ks_heat_public_host = $vip_public_fqdn
  $ks_heat_public_port = '8004'
  $ks_heat_cfn_public_port = '8000'
  $ks_heat_cloudwatch_public_port = '8003'
  $ks_heat_public_proto = 'http'
  $heat_auth_encryption_key = 'secrete'

  # Ceph
  $ceph_fsid = '4a158d27-f750-41d5-9e7f-26ce4c9d2d45'
  $ceph_mon_secret = 'secrete'
  $ceph_public_network = $public_network
  $ceph_cluster_network = $storage_network
}
