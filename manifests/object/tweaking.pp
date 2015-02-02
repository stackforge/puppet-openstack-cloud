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
# Swift tweaking
#
class cloud::object::tweaking {
  kmod::load { 'ip_conntrack': }

  $swift_tuning = {
    'net.ipv4.tcp_tw_recycle'                           => { value => 1 },
    'net.ipv4.tcp_tw_reuse'                             => { value => 1 },
    'net.ipv4.tcp_syncookies'                           => { value => 0 },
    'net.ipv4.ip_local_port_range'                      => { value => "1024\t65000" },
    'net.core.netdev_max_backlog'                       => { value => 300000 },
    'net.ipv4.tcp_sack'                                 => { value => 0 },
  }

  case $::osfamily {
    'Debian' : {
      $debian_swift_tuning = {
        'net.ipv4.netfilter.ip_conntrack_max'                    => { value => 524288 },
        'net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait'  => { value => 2 },
        'net.ipv4.netfilter.ip_conntrack_tcp_timeout_close_wait' => { value => 2 },
      }
      $swift_tuning_real = merge($swift_tuning, $debian_swift_tuning)
    }
    default : {
      $redhat_swift_tuning = {
        'net.netfilter.nf_conntrack_max'                    => { value => 524288 },
        'net.netfilter.nf_conntrack_tcp_timeout_time_wait'  => { value => 2 },
        'net.netfilter.nf_conntrack_tcp_timeout_close_wait' => { value => 2 },
      }
      $swift_tuning_real = merge($swift_tuning, $redhat_swift_tuning)
    }
  }

  $require = {
    require => Kmod::Load['ip_conntrack']
  }

  create_resources(sysctl::value,$swift_tuning_real,$require)

  file { '/var/log/swift':
    ensure => directory,
    owner  => swift,
    group  => swift,
  }

  logrotate::rule { 'swift':
    path          => '/var/log/swift/*.log',
    rotate        => 7,
    rotate_every  => 'day',
    missingok     => true,
    ifempty       => false,
    compress      => true,
    delaycompress => true,
  }
}
