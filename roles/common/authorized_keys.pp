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
#
# SSH authorized_keys
#

class authorized_keys ($keys, $account='root', $home = '') {
    # This line allows default homedir based on $account variable.
    # If $home is empty, the default is used.
    $rhome = $account ? {'root' => '/root', default => $home}
    $homedir = $rhome ? {'' => "/home/${account}", default => $rhome}
    file { "${homedir}/.ssh":
        ensure  => directory,
        owner   => $ensure ? {'present' => $account, default => undef },
        group   => $ensure ? {'present' => $account, default => undef },
        mode    => '0755',
    }
    file { "${homedir}/.ssh/authorized_keys":
        owner   => $ensure ? {'present' => $account, default => undef },
        group   => $ensure ? {'present' => $account, default => undef },
        mode    => '0644',
        require => File["${homedir}/.ssh"],
    }

    define addkey{
        exec{"key-${name}":
            command => "/bin/echo '${name}' >> ${homedir}/.ssh/authorized_keys",
            unless  => "/bin/grep -xFq '${name}' ${homedir}/.ssh/authorized_keys",
            require => File["${homedir}/.ssh/authorized_keys"],
        }
    }
    addkey{$keys:;}
}
