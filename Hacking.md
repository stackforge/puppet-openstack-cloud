## Testing

* [eNoCloud](gitolite@labs.enovance.com:ci-openstack-upgrade -b arch-tester)
* [eDeploy-lxc](https://github.com/enovance/edeploy-lxc)


## Syntax checks

* [Vi plugin](https://github.com/scrooloose/syntastic)
  1. Install syntastic (using bundle, see https://github.com/sbadia/grimvim/blob/master/vimrc#L21)
  2. Install puppet and puppet-lint packages
  3. Run vi [example](http://pub.sebian.fr/pub/syntastic.png)

* Manual launch:
  1. cd openstack-puppet-ci
  2. bundle install (or create a rvm : rvm use ruby-1.9.3-p385;rvm gemset use puppet-dev)
  3. rake lint

### Run spec test from a train (offline rake spec)

The rake task « spec » is an alias to `spec_prep` + `spec_standalone` + `spec_clean`.

If you don't have a internet connection, just run before (in order to populate
fixtures):

>     rake spec_prep

And then in your train:

>     rake spec_standalone
