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
# == Class: cloud::dashboard
#
# Installs the OpenStack Dashboard (Horizon)
#
# === Parameters:
#
# [*ks_keystone_internal_host*]
#   (optional) Internal address for endpoint.
#   Defaults to '127.0.0.1'
#
# [*secret_key*]
#   (optional) Secret key. This is used by Django to provide cryptographic
#   signing, and should be set to a unique, unpredictable value.
#   Defaults to 'secrete'
#
# [*horizon_port*]
#   (optional) Port used to connect to OpenStack Dashboard
#   Defaults to '80'
#
# [*api_eth*]
#   (optional) Which interface we bind the Horizon server.
#   Defaults to '127.0.0.1'
#
# [*servername*]
#   (optional) DNS name used to connect to Openstack Dashboard.
#   Default value fqdn.
#
# [*listen_ssl*]
#   (optional) Enable SSL on OpenStack Dashboard vhost
#   It requires SSL files (keys and certificates)
#   Defaults false
#
# [*keystone_proto*]
#   (optional) Protocol (http or https) of keystone endpoint.
#   Defaults to 'http'
#
# [*keystone_host*]
#   (optional) IP / Host of keystone endpoint.
#   Defaults '127.0.0.1'
#
# [*keystone_port*]
#   (optional) TCP port of keystone endpoint.
#   Defaults to '5000'
#
# [*debug*]
#   (optional) Enable debug or not.
#   Defaults to true
#
# [*horizon_cert*]
#   (required with listen_ssl) Certificate to use for SSL support.
#
# [*horizon_key*]
#   (required with listen_ssl) Private key to use for SSL support.
#
# [*horizon_ca*]
#   (required with listen_ssl) CA certificate to use for SSL support.
#
# [*ssl_forward*]
#   (optional) Forward HTTPS proto in the headers
#   Useful when activating SSL binding on HAproxy and not in Horizon.
#   Defaults to false

class cloud::dashboard(
  $ks_keystone_internal_host = '127.0.0.1',
  $secret_key                = 'secrete',
  $horizon_port              = 80,
  $horizon_ssl_port          = 443,
  $servername                = $::fqdn,
  $api_eth                   = '127.0.0.1',
  $keystone_host             = '127.0.0.1',
  $keystone_proto            = 'http',
  $keystone_port             = 5000,
  $debug                     = true,
  $listen_ssl                = false,
  $horizon_cert              = undef,
  $horizon_key               = undef,
  $horizon_ca                = undef,
  $ssl_forward               = false,
  $os_endpoint_type          = undef
) {

  # We build the param needed for horizon class
  $keystone_url = "${keystone_proto}://${keystone_host}:${keystone_port}/v2.0"

  # Apache2 specific configuration
  if $ssl_forward {
    $setenvif = ['X-Forwarded-Proto https HTTPS=1']
  } else {
    $setenvif = []
  }
  $vhost_extra_params = {
    'add_listen' => true,
    'setenvif'   => $setenvif
  }
  ensure_resource('class', 'apache', {
    default_vhost => false
  })

  class { 'horizon':
    secret_key              => $secret_key,
    can_set_mount_point     => 'False',
    # fqdn can can be ambiguous since we use reverse DNS here,
    # e.g: 127.0.0.1 instead of a public IP address.
    # We force $api_eth to avoid this situation
    fqdn                    => $api_eth,
    servername              => $servername,
    bind_address            => $api_eth,
    swift                   => true,
    keystone_url            => $keystone_url,
    cache_server_ip         => false,
    django_debug            => $debug,
    neutron_options         => { 'enable_lb' => true },
    listen_ssl              => $listen_ssl,
    horizon_cert            => $horizon_cert,
    horizon_key             => $horizon_key,
    horizon_ca              => $horizon_ca,
    vhost_extra_params      => $vhost_extra_params,
    openstack_endpoint_type => $os_endpoint_type,
  }

  if ($::osfamily == 'Debian') {
    # TODO(Gonéri): HACK to ensure Horizon can cache its files
    $horizon_var_dir = ['/var/lib/openstack-dashboard/static/js','/var/lib/openstack-dashboard/static/css']
    file {$horizon_var_dir:
      ensure => directory,
      owner  => 'horizon',
      group  => 'horizon',
    }
  }

  @@haproxy::balancermember{"${::fqdn}-horizon":
    listening_service => 'horizon_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $horizon_port,
    options           => "check inter 2000 rise 2 fall 5 cookie ${::hostname}"
  }

  if $listen_ssl {

    @@haproxy::balancermember{"${::fqdn}-horizon-ssl":
      listening_service => 'horizon_ssl_cluster',
      server_names      => $::hostname,
      ipaddresses       => $api_eth,
      ports             => $horizon_ssl_port,
      options           => "check inter 2000 rise 2 fall 5 cookie ${::hostname}"
    }

  }

}
