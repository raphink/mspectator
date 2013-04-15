mspectator
==========

Use RSpec and MCollective to test your fleet

# Goal

This project provides a way to test your fleet of servers using RSpec and MCollective.

It is similar to the [serverspec](http://serverspec.org) project, but it uses MCollective instead of SSH as a network facility, and it allows to test more than a host at a time.

## Example

The matchers allow to test hosts based on filters, using classes and facts. Below is an example:

    describe "apache::server" do
      it { should find_nodes(10).or_less.with_agent('spec') }
      it { should have_certificate.signed }
      it { should pass_puppet_spec }

      context "when on Debian", :facts => [:operatingsystem => "Debian"] do
        it { should find_nodes(5).or_more }
        # Not implemented yet
        #it { should have_service('apache2').with(
        #  :ensure => 'running',
        #  :enable => 'true'
        #  )
        #}
        it { should have_package('apache2') }
        it { should have_user('www-data') }
      end
    end

# Architecture

## Network architecture and libraries

The general architecture of the solution is the following:

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


