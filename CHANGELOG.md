##2014-04-22 - Features release 1.2.0
###Summary
* Now supports Ubuntu 12.04
* Now supports Now supports Red Hat OpenStack Platform 4
* Can be deployed on 3 nodes
* Add cluster note type support for RabbitMQ configuration
* Block storage can now be backend by multiple RBD pools

####Bugfixes
* Fix a bug in Horizon in HTTP/HTTPS binding

####Known Bugs
* No known bugs

##2014-04-01 - Features release 1.1.0
###Summary
* Updated puppetlabs-rabbitmq to 3.1.0 (RabbitMQ to 3.2.4)
* Add Cinder Muli-backend support
* NetApp support for Cinder as a backend
* Keystone uses now MySQL for tokens storage (due to several issues with Memcache backend)
* Back to upstream puppet-horizon from stackforge
* Servername parameter support in Horizon configuration to allow SSL redirections
* puppet-openstack-cloud module QA is done by Travis
* network: add dhcp\_lease\_duration parameter support

####Bugfixes
* neutron: increase agent polling interval

####Known Bugs
* Bug in Horizon in HTTP/HTTPS binding (fixed in 1.2.0)

##2014-03-13 - First stable version 1.0.0
###Summary
* First stable version.

####Bugfixes
* No

####Known Bugs
* No known bugs
