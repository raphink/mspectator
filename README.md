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
     |       | (check_action, *args)       |           |     Serverspec::Backend::Puppet     |
     |       v                             |           |              or                     |
     |  MCollective::RPC#rpcclient         |           |      Serverspec::Backend::Exec      |
     |       |                             |           |           ^                         |
     |       +                             |           |           | (check_action, *args)   |
     |       |                             |           |           +                         |
     |       +------------------------------------------->  MCollective::RPC::Agent          |
     |                action, *args        |           |                                     |
     |                                     |           |                                     |
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
      context "when on Debian", :facts => [:operatingsystem => "Debian"] do
        it { should have_service('apache2').with(
          :ensure => 'running',
          :enable => 'true'
          )
        }
      end
    end

The `with` method of the matchers may look very similar to those of [rspec-puppet](http://rspec-puppet.com), but instead of testing the catalog, they will actually use the Puppet providers to check the system.

