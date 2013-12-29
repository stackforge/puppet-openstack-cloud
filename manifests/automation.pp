#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
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
# Puppet Master node
#

class privatecloud::automation{

  # Ensure git is installed
  class { 'git': }

  # Install Puppet submodules
  vcsrepo { '/etc/puppet/modules/':
    ensure   => latest,
    provider => git,
    source   => 'gitolite@git.labs.enovance.com:puppet.git',
    revision => "openstack-${os_params::os_release}/master",
  }
  ->
  exec { '/usr/bin/git submodule init':
    cwd => '/etc/puppet/modules',
  }
  ->
  exec { '/usr/bin/git submodule update':
    cwd => '/etc/puppet/modules',
  }

  # Install Puppet manifests
  vcsrepo { '/etc/puppet/manifests/':
    ensure   => latest,
    provider => git,
    source   => 'git.labs.enovance.com:openstack-puppet-ci.git',
    revision => 'master',
  }

}
