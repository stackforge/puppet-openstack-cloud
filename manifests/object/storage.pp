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
# Swift Storage node
#
class cloud::object::storage (
  $storage_eth           = '127.0.0.1',
  $swift_zone            = undef,
  $object_port           = '6000',
  $container_port        = '6001',
  $account_port          = '6002',
  $fstype                = 'xfs',
  $device_config_hash    = {},
  $ring_container_device = 'sdb',
  $ring_account_device   = 'sdb',
) {

  include 'cloud::object'

  class { 'swift::storage':
    storage_local_net_ip => $storage_eth,
  }

  Rsync::Server::Module {
    incoming_chmod  => 'u=rwX,go=rX',
    outgoing_chmod  => 'u=rwX,go=rX',
  }

  Swift::Storage::Server {
    #devices                => $devices,
    storage_local_net_ip    => $storage_eth,
    workers                 => inline_template('<%= @processorcount.to_i / 2 %>'),
    replicator_concurrency  => 2,
    updater_concurrency     => 1,
    reaper_concurrency      => 1,
    require                 => Class['swift'],
    mount_check             => true,
  }
  # concurrency at 2 and 1 seems better see
  # http://docs.openstack.org/trunk/openstack-object-storage/admin/content/general-service-tuning.html

  swift::storage::server { $account_port:
    type             => 'account',
    config_file_path => 'account-server.conf',
    pipeline         => ['healthcheck', 'account-server'],
    log_facility     => 'LOG_LOCAL2',
  }

  swift::storage::server { $container_port:
    type             => 'container',
    config_file_path => 'container-server.conf',
    workers          => inline_template("<%= @processorcount.to_i / 2 %>
db_preallocation = on
allow_versions = on
"), # great hack :(
    pipeline         => ['healthcheck', 'container-server'],
    log_facility     => 'LOG_LOCAL4',
  }

  swift::storage::server { $object_port:
    type             => 'object',
    config_file_path => 'object-server.conf',
    pipeline         => ['healthcheck', 'recon', 'object-server'],
    log_facility     => 'LOG_LOCAL6',
  }

  $swift_components = ['account', 'container', 'object']
  swift::storage::filter::recon { $swift_components : }
  swift::storage::filter::healthcheck { $swift_components : }

  create_resources("swift::storage::${fstype}", $device_config_hash)
  create_resources('cloud::object::set_io_scheduler', $device_config_hash)

  @@ring_container_device { "${storage_eth}:${container_port}/${ring_container_device}":
    zone        => $swift_zone,
    weight      => '100.0',
  }
  @@ring_account_device { "${storage_eth}:${account_port}/${ring_account_device}":
    zone        => $swift_zone,
    weight      => '100.0',
  }
  $object_urls = prefix(keys($device_config_hash), "${storage_eth}:${object_port}/")
  @@ring_object_device {$object_urls:
    zone        => $swift_zone,
    weight      => '100.0',
  }

  Swift::Ringsync<<| |>> ->
    Swift::Storage::Server[$container_port] ->
    Swift::Storage::Server[$account_port] ->
    Swift::Storage::Server[$object_port]

}
