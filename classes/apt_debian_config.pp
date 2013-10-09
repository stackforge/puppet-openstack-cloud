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

# APT configuration if we use Debian

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
    

    apt::source { "openstack_grizzly":
      location          => "[trusted=1] http://seattle.apt-proxy.gplhost.com/debian/",
      release           => "grizzly",
      include_src       => false,
    }

    apt::source {'openstack_grizzly_backports':
      location          => "[trusted=1] http://seattle.apt-proxy.gplhost.com/debian/",
        release => 'grizzly-backports',
        include_src => false,
    }

     apt::source { "mariadb":
       location          => "http://ftp.igh.cnrs.fr/pub/mariadb/repo/5.5-galera/debian/",
       release           => "wheezy",
       include_src       => false,
       key_server        => "keyserver.ubuntu.com",
       key               => "1BB943DB",
    }

    apt::source { "debian_wheezy":
      location          => "http://ftp.us.debian.org/debian/",
      release           => "wheezy",
      repos             => "main contrib non-free",
      include_src       => false
    }

    apt::source { "debian_wheezy_security":
      location          => "http://security.debian.org/",
      release           => "wheezy/updates",
      repos             => "main",
      include_src       => false
    }

    apt::source { "debian_wheezy_backports":
      location          => "http://ftp.us.debian.org/debian/",
      release           => "wheezy-backports",
      repos             => "main",
      include_src       => false
    }


# We don't include Ceph here, since APT is managed by Ceph Puppet module

}


