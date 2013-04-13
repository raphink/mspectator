mspectator
==========

Use RSpec and MCollective to test your fleet

# Goal

This project aims to provide a way to test your fleet of servers using RSpec and MCollective.

It will be similar to the [serverspec](http://serverspec.org) project, but it will use MCollective instead of SSH as a network facility, and it will allow to test more than a host at a time.

# Architecture

## Network architecture and libraries

The general architecture of the solution will be the following:

     +-------------------------------------+           +-------------------------------------+
     |      Client                         |           |        Server                       |
     |-------------------------------------|           |-------------------------------------|
     |                                     |           |                                     |
     |     rspec                           |           |                                     |
     |       +                             |           |                                     |
     |       | (check_action, *args)       |           |                                     |
     |       v                             |           |                                     |
     |  MCollective::RPC#rpcclient         |           |      Serverspec::Backend::Puppet    |
     |       |                             |           |           ^                         |
     |       +                             |           |           | (check_action, *args)   |
     |       |                             |           |           +                         |
     |       +------------------------------------------->  MCollective::RPC::Agent          |
     |                action, *args        |           |                                     |
     |                                     |           |                                     |
     +-------------------------------------+           +-------------------------------------+


The components required for this architecture are:

* [RSpec](http://rspec.info), on the client side;
* The [serverspec](http://serverspec.org) backends and matchers, on the server side;
* The [spec MCollective agent](https://github.com/camptocamp/puppet-spec/tree/master/files/mcollective/agent) on the server side;
* A series of matchers on the client side to describe the hosts being tested.


## RSpec architecture

The matchers will allow to test hosts based on filters, using classes and facts. Below is an example:

    describe "apache::server" do
      it { should find_nodes(10).or_less }
      it { should have_certificate }
      context "when on Debian", :facts => [:operatingsystem => "Debian"] do
        it { should find_nodes(5).or_more }
        it { should have_service('apache2').with(
          :ensure => 'running',
          :enable => 'true'
          )
        }
        it { should have_package('apache2') }
        it { should have_user('www-data') }
      end
    end

A few notes on this:

* The `find_nodes` matcher will do a `discover` lookup. There is an example [in my serverspec fork](https://github.com/raphink/serverspec/blob/dev/mcollective_backend/lib/serverspec/matchers/find_nodes.rb) using the [MCollective serverspec backend](https://github.com/raphink/serverspec/blob/dev/mcollective_backend/lib/serverspec/backend/mcollective.rb);
* The `have_certificate` matcher (and others, such as `be_monitored`, `be_backuped`, etc.) will require at least two MCollective calls:
 * A `discover` call to find the nodes matching the current filters (classes and facts);
 * An call on a specific agent (`puppetca`, `nrpe`, etc.) to test if the found nodes actually pass the tests.
* The `with` method of the `have_service` matcher may look very similar to those of [rspec-puppet](http://rspec-puppet.com), but instead of testing the catalog, they will actually use the Puppet providers to check the system.
* The tested resources might *not* be managed by Puppet/chef at all. The fact that the system uses Puppet providers to achieve the tests does not require the resources to have been in a Puppet catalog at any time. It is just a practical way of describing these resources.



