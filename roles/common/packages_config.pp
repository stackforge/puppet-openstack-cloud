#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Emilien Macchi <emilien.macchi@enovance.com>
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

# APT configuration

class os_packages_config {

    class{'apt':
      always_apt_update    => false,
      purge_sources_list   => true,
      purge_sources_list_d => true,
      purge_preferences_d  => true,
    }

    # Ensure apt is configured before every package installation
    Class['os_packages_config'] -> Package <| |>

    # configure apt periodic updates
    apt::conf { 'periodic':
      priority  => '10',
      content   => "
APT::Periodic::Update-Package-Lists 1;
APT::Periodic::Download-Upgradeable-Packages 1;
";
}


# OS specific repositories
    case $::operatingsystem {
      'Debian': {
        # Official Debian repositories
        apt::source {'debian_main':
          location    => 'http://ftp2.fr.debian.org/debian/',
          release     => 'wheezy',
          repos       => 'main contrib non-free',
          include_src => false,
        }

        apt::source {'debian_backports':
          location    => 'http://ftp2.fr.debian.org/debian/',
          release     => 'wheezy-backports',
          include_src => false,
        }

        apt::source {'debian_security':
          location    => 'http://security.debian.org/',
          release     => 'wheezy/updates',
          repos       => 'main',
          include_src => false,
        }

        apt::source {'mariadb':
          location    => 'http://ftp.igh.cnrs.fr/pub/mariadb/repo/5.5/debian',
          release     => 'wheezy',
          include_src => false,
          key_server  => 'keyserver.ubuntu.com',
          key         => '1BB943DB',
        }
      } # Debian

      'Ubuntu': {
        apt::source { 'ubuntu_precise':
          location          => 'http://us.archive.ubuntu.com/ubuntu',
          release           => 'precise',
          repos             => 'main universe multiverse',
          include_src       => false
        }

        apt::source { 'ubuntu_precise_update':
          location          => 'http://us.archive.ubuntu.com/ubuntu',
          release           => 'precise-updates',
          repos             => 'main universe multiverse',
          include_src       => false
        }

        apt::source { 'ubuntu_precise_security':
          location          => 'http://security.ubuntu.com/ubuntu',
          release           => 'precise-security',
          repos             => 'main universe multiverse',
          include_src       => false
        }

        apt::source {'mariadb':
          location    => 'http://ftp.igh.cnrs.fr/pub/mariadb/repo/5.5/ubuntu',
          release     => 'precise',
          include_src => false,
          key_server  => 'keyserver.ubuntu.com',
          key         => '1BB943DB',
        }
      } # Ubuntu
      default: {
        fail("Operating system (${::operatingsystem}) not supported yet" )
      }
    }

# Common packages for Debian / Ubuntu
    case $::operatingsystem {
      /^(Debian|Ubuntu)$/: {
        # OpenStack / Ceph / Specific Backports
        apt::source {'cloud.pkgs.enovance.com':
          location    => "[trusted=1 arch=amd64] http://cloud.pkgs.enovance.com/${::lsbdistcodename}-${os_params::os_release}",
          release     => $os_params::os_release,
          include_src => false,
          key_server  => 'keyserver.ubuntu.com',
          key         => '5D964F0B',
        }

        # Specific to eNovance (SSH keys, etc)
        apt::source {'enovance':
          location    => 'http://***REMOVED***@repo.enovance.com/apt/',
          release     => 'squeeze',
          repos       => 'main contrib non-free',
          key         => '3A964515',
          key_source  => 'http://***REMOVED***@repo.enovance.com/apt/key/enovance.gpg',
          include_src => true,
        }
      }
      default: {
        fail("Operating system (${::operatingsystem}) not supported yet" )
      }
    }

# We don't include Ceph here, since APT is managed by Ceph Puppet module

}
