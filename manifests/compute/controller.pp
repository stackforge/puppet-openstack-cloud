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
# Compute controller node
#
class cloud::compute::controller(
  $ks_keystone_internal_host            = '127.0.0.1',
  $ks_nova_password                     = 'novapassword',
  $neutron_metadata_proxy_shared_secret = 'asecreteaboutneutron',
  $api_eth                              = '127.0.0.1',
  $spice_port                           = 6082,
  $ks_nova_public_port                  = 8774,
  $ks_ec2_public_port                   = 8773,
  $ks_metadata_public_port              = 8775
){

  warning('This class is deprecated. You should use cloud::compute::api,scheduler,conductor,consoleauth,consoleproxy,cert classes')

  include 'cloud::compute'

  class { 'cloud::compute::cert': }
  class { 'cloud::compute::conductor': }
  class { 'cloud::compute::consoleauth': }
  class { 'cloud::compute::scheduler': }

  class { 'cloud::compute::api':
    ks_keystone_internal_host            => $ks_keystone_internal_host,
    ks_nova_password                     => $ks_nova_password,
    api_eth                              => $api_eth,
    neutron_metadata_proxy_shared_secret => $neutron_metadata_proxy_shared_secret,
    ks_nova_public_port                  => $ks_nova_public_port,
    ks_ec2_public_port                   => $ks_ec2_public_port,
    ks_metadata_public_port              => $ks_metadata_public_port,
  }

  class { 'cloud::compute::consoleproxy':
    api_eth    => $api_eth,
    spice_port => $spice_port,
  }

}
