#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Mehdi Abaakouk <mehdi.abaakouk@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
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
# Parameters of eNovance CI
#

class os_params {

  # General parameters
  $compute = False
  $debug = False
  $dns_ips = ['10.68.0.2']
  $install_packages = False
  $os_release = 'havana'
  $region = 'enovance-ci'
  $site_domain = 'enovance.com'
  $storage = True
  $verbose = False

  # Root hashed password
  # ToDo(EmilienM): Disable root user in all nodes and use sudo
  $root_password = '$1$2X/chMfy$CuJ4xPZY0WO2pRfIm5djn/'


  # OpenStack Identity
  $identity_roles_addons = ['SwiftOperator', 'ResellerAdmin']
  $keystone_allowed_hosts = ['os-ci-test%', '10.68.0.%']
  $keystone_db_host = '10.68.0.47'
  $keystone_db_password = 'H3YPSYaKbKP40DuvHHpdrhYFVpa10A'
  $keystone_db_user = 'keystone'
  $keystone_memchached = ['10.68.0.47:11211']
  $keystone_port = '5000'
  $ks_admin_email = 'dev@enovance.com'
  $ks_admin_password = 'Xokoph5io2aenaoh0nuiquei9aineigo'
  $ks_admin_tenant = 'admin'
  $ks_admin_token = 'iw3feche3JeeYo9mejoohaugai3thohahwo9tiuyoe5Thier8Eiwah8K'
  $ks_keystone_internal_host = 'os-ci-test3.enovance.com'
  $ks_keystone_internal_port = '5000'
  $ks_keystone_internal_proto = 'http'
  $ks_keystone_admin_host = 'os-ci-test3.enovance.com'
  $ks_keystone_admin_port = '35357'
  $ks_keystone_admin_proto = 'http'
  $ks_keystone_public_host = 'os-ci-test3.enovance.com'
  $ks_keystone_public_port = '5000'
  $ks_keystone_public_proto = 'http'

  # Swift
  $ks_swift_internal_proto = 'http'
  $ks_swift_admin_host = 'os-ci-test3.enovance.com'
  $ks_swift_admin_port = '8080'
  $ks_swift_admin_proto = 'http'
  $ks_swift_dispersion_password = 'aipee1die1eeSohph9yae8eeluthaleu'
  $ks_swift_internal_host = 'os-ci-test3.enovance.com'
  $ks_swift_internal_port = '8080'
  $ks_swift_password = 'cwnu6Eeph4jahsh5wooch5Panahjaidie8'
  $ks_swift_public_host = 'os-ci-test3.enovance.com'
  $ks_swift_public_port = '8080'
  $ks_swift_public_proto = 'http'
  $replicas = '3'
  $statsd_host = '127.0.0.1'
  $statsd_port = '4125'
  $swift_cors_allow_origin = 'http://os-ci-test3.enovance.com'
  $swift_hash_suffix = 'ni2aseiWi8ich3oo'
  $swift_memchached = ['10.68.0.47:11211']
  $swift_port = '8080'
  $swift_rsync_max_connections = '5'
  $os_swift_zone = {
    'os-ci-test8' => 1,
    'os-ci-test9' => 2,
    'os-ci-test12' => 3,
  }

  # MySQL
  $mysql_password = 'TRG33WDCAvmLqtUv5MwfGxDnxTyaciMAV4RFe044'
  $mysql_debian_sys_maint = 'HFCeEKGG6DBQEaYUEDjGITcbzRWDmv'
  $galera_master = 'os-ci-test3'
  $galera_nextserver = {
    'os-ci-test3' => '', # 10.68.0.47
    'os-ci-test4' => '10.68.0.48',
  }

  # LoadBalancer
  $keepalived_email = "dev@${site_domain}"
  $keepalived_smtp = "mxi1.${site_domain}"
  $haproxy_auth   = 'root:enovance'

  # Horizon
  $horizon_port = '80'

  # MongoDB
  $mongodb_location = ''

  # RabbitMQ
  $rabbit_names = ['os-ci-test3']
  $rabbit_hosts = ['10.68.0.47:5672']
  $rabbit_password = 'okaeTh3aiwiewohk'
  # Useful when we need a single Rabbit host (like Sensu needs)
  $rabbit_main_host = 'os-ci-test3'


  # Neutron
  $external_int = 'eth1'
  $ks_neutron_admin_host = 'os-ci-test3.enovance.com'
  $ks_neutron_admin_port = '9696'
  $ks_neutron_admin_proto = 'http'
  $ks_neutron_internal_host = 'os-ci-test3.enovance.com'
  $ks_neutron_internal_port = '9696'
  $ks_neutron_internal_proto = 'http'
  $ks_neutron_password = 'AJJTg2fSWrE4X4L1rhKJI74njLpFB0'
  $ks_neutron_public_host = 'os-ci-test3.enovance.com'
  $ks_neutron_public_port = '9696'
  $ks_neutron_public_proto = 'http'
  $neutron_allowed_hosts = ['os-ci-test%', '10.60.0.%']
  $neutron_db_host = '10.68.0.47'
  $neutron_db_password = 'JCywR7Kt52Hi2hJTtpTb6LCGfo243x'
  $neutron_db_user = 'neutron'
  $neutron_port = '9696'
  $tunnel_int   = 'eth0'

  # Nova
  $ks_nova_admin_host = 'os-ci-test3.enovance.com'
  $ks_nova_internal_host = 'os-ci-test3.enovance.com'
  $ks_nova_password = 'WeiveKed1Ahmel7ohfieya6daiquIe'
  $ks_nova_public_host = 'os-ci-test3.enovance.com'
  $ks_nova_public_proto = 'http'
  $nova_allowed_hosts = ['os-ci-test%', '10.60.0.%']
  $nova_db_host = '10.68.0.47'
  $nova_db_password = 'Ae3tooch8shohNai9ooqueik9gaevo'
  $nova_db_user = 'nova'
  $nova_port = '8774'
  $ks_nova_admin_host = 'os-ci-test3.enovance.com'
  $ks_nova_admin_port = '8774'
  $ks_nova_admin_proto = 'http'
  $ks_nova_internal_host = 'os-ci-test3.enovance.com'
  $ks_nova_internal_port = '8774'
  $ks_nova_internal_proto = 'http'
  $ks_nova_public_host = 'os-ci-test3.enovance.com'
  $ks_nova_public_port = '8774'
  $ks_nova_public_proto = 'http'

  # Glance
  $glance_allowed_hosts = ['os-ci-test%', '10.60.0.%']
  $glance_db_host = '10.68.0.47'
  $glance_db_password = 'uYgNjBzjMjv2fD0yD3LqiQQPKEKuXA'
  $glance_db_user = 'glance'
  $glance_port = '9292'
  $ks_glance_admin_host = 'os-ci-test3.enovance.com'
  $ks_glance_admin_port = '9292'
  $ks_glance_admin_proto = 'http'
  $ks_glance_internal_host = 'os-ci-test3.enovance.com'
  $ks_glance_internal_port = '9292'
  $ks_glance_internal_proto = 'http'
  $ks_glance_public_host = 'os-ci-test3.enovance.com'
  $ks_glance_public_port = '9292'
  $ks_glance_public_proto = 'http'
  $ks_glance_password = 'WUBDUbox7gDz3GP6EAYWGos9VBPh82'

  # Ceilometer
  $ceilometer_database_connection = 'mongodb://10.68.0.47/ceilometer'
  $ceilometer_secret = 'S45ILumu44rxn5u7spnbJws9XiWomc'
  $ks_ceilometer_admin_host = 'os-ci-test3.enovance.com'
  $ks_ceilometer_admin_port = '8776'
  $ks_ceilometer_admin_proto = 'http'
  $ks_ceilometer_internal_host = 'os-ci-test3.enovance.com'
  $ks_ceilometer_internal_port = '8776'
  $ks_ceilometer_internal_proto = 'http'
  $ks_ceilometer_password = 'eafhafbheafaefaejiiutiu7374aesf3aiNu'
  $ks_ceilometer_public_host = 'os-ci-test3.enovance.com'
  $ks_ceilometer_public_port = '8776'
  $ks_ceilometer_public_proto = 'http'

  # Cinder
  $cinder_allowed_hosts = ['os-ci-test%', '10.60.0.%']
  $cinder_db_host = '10.68.0.47'
  $cinder_db_password = 'BwgPjjqdbxiKvKm5JMaVrCaT8ePBwP'
  $cinder_db_user = 'cinder'
  $cinder_rbd_pool = 'cinder_volumes'
  $cinder_rbd_secret_uuid = '95c98032-ad65-5db8-f5d3-5bd09cd563ef'
  $cinder_rbd_user = 'cinder_rbd'
  $glance_api_version = '2'
  $ks_cinder_admin_host = 'os-ci-test3.enovance.com'
  $ks_cinder_admin_port = '8776'
  $ks_cinder_admin_proto = 'http'
  $ks_cinder_internal_host = 'os-ci-test3.enovance.com'
  $ks_cinder_internal_port = '8776'
  $ks_cinder_internal_proto = 'http'
  $ks_cinder_password = '768JIxDvnrBbwGaRRn5mHjrzz9jNJi'
  $ks_cinder_public_host = 'os-ci-test3.enovance.com'
  $ks_cinder_public_port = '8776'
  $ks_cinder_public_proto = 'http'

  # Heat
  $heat_db_host = '10.68.0.47'
  $heat_db_password = 'rooghah0phe1tieDeixoodo0quil8iox'
  $heat_db_user = 'heat'
  $ks_heat_admin_host = 'os-ci-test3.enovance.com'
  $ks_heat_admin_port = '8004'
  $ks_heat_admin_proto = 'http'
  $ks_heat_internal_host = 'os-ci-test3.enovance.com'
  $ks_heat_internal_port = '8004'
  $ks_heat_internal_proto = 'http'
  $ks_heat_password = 'EIMMvWvDPEvI08ggT2azYMhGdsNXe6'
  $ks_heat_public_host = 'os-ci-test3.enovance.com'
  $ks_heat_public_port = '8004'
  $ks_heat_public_proto = 'http'

}
