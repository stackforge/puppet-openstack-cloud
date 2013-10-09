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

# APT configuration if we use Ubuntu

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


    apt::source { "ubuntu_precise":
      location          => "http://us.archive.ubuntu.com/ubuntu",
      release           => "precise",
      repos             => "main universe multiverse",
      include_src       => false
    }

    apt::source { "ubuntu_precise_update":
      location          => "http://us.archive.ubuntu.com/ubuntu",
      release           => "precise-updates",
      repos             => "main universe multiverse",
      include_src       => false
    }

    apt::source { "ubuntu_precise_security":
      location          => "http://security.ubuntu.com/ubuntu",
      release           => "precise-security",
      repos             => "main universe multiverse",
      include_src       => false
    }

    apt::source { "openstack_backports":
      location          => "[trusted=1 arch=amd64] http://seattle.apt-proxy.gplhost.com/debian/",
      release           => "precise-grizzly-backports",
      include_src       => false,
    }

    apt::source { "misc":
      location          => "[trusted=1 arch=amd64] http://archive.gplhost.com/debian/",
      release           => "misc",
      include_src       => false,
    }

# Specific to Midonet
    apt::source { "test.midokura.com":
      location          => "[trusted=1 arch=amd64] http://orange:TaMXwvovFZ2TBW@apt.midokura.com/midonet/v1.1/test",
      release           => "precise",
      repos             => "main non-free",
      include_src       => false,
    }

# Specific to Midonet
    apt::source { "test-grizzly.midokura.com":
      location          => "[trusted=1 arch=amd64] http://orange:TaMXwvovFZ2TBW@apt.midokura.com/midonet/v1.0/test-grizzly",
      release           => "precise",
      repos             => "main non-free",
      include_src       => false,
    }

     apt::source { "mariadb":
       location          => "http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu/",
       release           => "precise",
       include_src       => false,
       key_server        => "keyserver.ubuntu.com",
       key               => "1BB943DB",
    }

# We don't include Ceph here, since APT is managed by Ceph Puppet module

}
