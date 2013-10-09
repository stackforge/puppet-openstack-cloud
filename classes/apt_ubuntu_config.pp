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

# APT configuration if we use Ubuntu Precise

class os_apt_config {

    class{"apt":
      always_apt_update    => true,
      purge_sources_list   => true,
      purge_sources_list_d => true,
      purge_preferences_d  => true,
    }

    # Ensure apt is configured before every package installation
    Class["os_apt_config"] -> Package <| |> 

    # configure apt periodic updates
    apt::conf { 'periodic':
      priority        => '10',
      content          => "
APT::Periodic::Update-Package-Lists 1;
APT::Periodic::Download-Upgradeable-Packages 1;
";
}

  apt::source {'cloud.pkgs.enovance.com':
      location    => 'http://cloud.pkgs.enovance.com/precise-havana',
      release     => 'havana',
      include_src => false,
      key_server  => "keyserver.ubuntu.com",
      key         => "5D964F0B",
  }

  apt::source {'enovance':
      location    => 'http://***REMOVED***@repo.enovance.com/apt/',
      release     => 'squeeze',
      repos       => "main contrib non-free",
      key         => "3A964515",
      key_source  => "http://***REMOVED***@repo.enovance.com/apt/key/enovance.gpg",
      include_src => true,
  }

# We don't include Ceph here, since APT is managed by Ceph Puppet module

}
