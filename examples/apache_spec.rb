require 'spec_helper'

describe 'apache' do
  it { should find_nodes(100).or_less }
  it { should pass_puppet_spec }
  it { should have_certificate.signed }

  context 'when on Debian',
    :facts => { :operatingsystem => 'Debian' } do

    it { should find_nodes(5).using_agent('spec') }
    it { should have_package('apache2.2-common') }
    it { should_not have_package('httpd') }
    it { should have_service('apache2').with(
      :ensure => 'running'
    ) }
    it { should have_file('/etc/apache2/apache2.conf') }
    it { should have_directory('/etc/apache2/conf.d') }
    it { should have_user('www-data') }
  end

  context 'when using SSL', :classes => ['apache::ssl'] do
    it { should find_nodes(50).or_more }
    it { should have_package('ca-certificates') }
  end
end
