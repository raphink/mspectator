mspectator
==========

[![Gem Version](https://img.shields.io/gem/v/mspectator.svg)](https://rubygems.org/gems/mspectator)
[![Gem Downloads](https://img.shields.io/gem/dt/mspectator.svg)](https://rubygems.org/gems/mspectator)
[![Gemnasium](https://img.shields.io/gemnasium/raphink/mspectator.svg)](https://gemnasium.com/raphink/mspectator)

Use RSpec and MCollective to test your fleet

# Goal

This project provides a way to test your fleet of servers using RSpec and MCollective.

It is similar to the [serverspec](http://serverspec.org) project, but it uses MCollective instead of SSH as a network facility, and it allows to test more than a host at a time.

# Installing

## Client side

On the client side (where you run `rspec`), you need `mspectator` itself:

    gem install mspectator

You also need to have an MCollective client set up, as well as RSpec.


## Server side

On the server side (the hosts you are testing), you need:

* An MCollective node with the [`spec` agent](https://github.com/camptocamp/puppet-spec/tree/master/files/mcollective/agent);
* [`serverspec`](http://serverspec.org);


# Example

The matchers allow to test hosts based on filters, using classes and facts. Below is an example:

    require 'mspectator'
    
    describe "apache::server" do
      it { should find_nodes(10).or_less.with_agent('spec') }
      it { should have_certificate.signed }
      it { should pass_puppet_spec }

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
     |  MCollective::RPC#rpcclient         |           |         Specinfra::Backend::Exec    |
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


