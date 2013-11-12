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
# Horizon dashboard

class os_role_horizon {

#  package{ 'openstack-dashboard-apache':
#    ensure => latest
#  }

  apache::vhost { 'horizon':
    servername         => $::fqdn,
    port               => $os_params::horizon_port,
    docroot            => '/var/www',
    docroot_owner      => 'www-data',
    docroot_group      => 'www-data',
    error_log_file     => "${::fqdn}_horizon_error.log",
    access_log_file    => "${::fqdn}_horizon_access.log",
    configure_firewall => false,
    custom_fragment    => inline_template('
WSGIScriptAlias / /usr/share/openstack-dashboard/openstack_dashboard/wsgi/django.wsgi
WSGIDaemonProcess horizon user=www-data group=www-data
   Alias /static /usr/share/openstack-dashboard/openstack_dashboard/static

    DocumentRoot /var/www

    <Directory />
        AllowOverride None
    </Directory>

    <Directory /usr/share/openstack-dashboard/openstack_dashboard/wsgi/>
        Order allow,deny
        Allow from all
    </Directory>

    Alias /static/horizon /usr/share/pyshared/horizon/static/horizon

    <Directory /usr/share/pyshared/horizon/static/horizon>
        Order allow,deny
        Allow from all
    </Directory>

    <Directory /usr/share/openstack-dashboard/openstack_dashboard/static/>
        Order allow,deny
        Allow from all
    </Directory>
')
  }


} # Class:: os_role_horizon
