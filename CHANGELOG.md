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
* No known bugs

##2014-03-13 - First stable version 1.0.0
###Summary
* First stable version.

####Bugfixes
* No

####Known Bugs
* No known bugs
