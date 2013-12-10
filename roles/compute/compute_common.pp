#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Mehdi Abaakouk <mehdi.abaakouk@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
#          Sebastien Badia <sebastien.badia@enovance.com>
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
# Compute Common (controller/hypervisor)
#

class os_compute_common(
  $nova_db_host            = $os_params::nova_db_host,
  $rabbit_hosts            = $os_params::rabbit_hosts,
  $rabbit_password         = $os_params::rabbit_password,
  $ks_glance_internal_host = $os_params::ks_glance_internal_host,
  $glance_port             = $os_params::glance_port,
  $verbose                 = $os_params::verbose,
  $debug                   = $os_params::debug
) {

  if !defined(Resource['nova_config']) {
    resources { 'nova_config':
      purge => true;
    }
  }

  $encoded_user = uriescape($os_params::nova_db_user)
  $encoded_password = uriescape($os_params::nova_db_password)

  class { 'nova':
    database_connection => "mysql://${encoded_user}:${encoded_password}@${nova_db_host}/nova?charset=utf8",
    rabbit_userid       => 'nova',
    rabbit_hosts        => $rabbit_hosts,
    rabbit_password     => $rabbit_password,
    glance_api_servers  => "http://${ks_glance_internal_host}:${glance_port}",
    verbose             => $os_params::verbose,
    debug               => $os_params::debug
  }

  nova_config {
    'DEFAULT/resume_guests_state_on_host_boot': value => true;
  }

}
