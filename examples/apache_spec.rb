require 'spec_helper'

describe 'apache' do
  it { should find_nodes(100).or_less }

  context 'when on Debian',
    :classes => ['apache'],
    :facts => { :operatingsystem => 'Debian' } do

    it { should find_nodes(5).using_agent('spec') }
    it { should have_package('apache2.2-common') }
    it { should_not have_package('httpd') }
  end

  context 'apache::ssl and operatingsystem=Debian' do
    it { should find_nodes(50).or_more }
    it { should have_package('ca-certificates') }
  end
end
