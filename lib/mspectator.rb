require 'mspectator/matchers'

require 'mcollective'
include ::MCollective::RPC

def apply_filters (mc, example)
  classes = example.metadata[:classes] || []
  facts = example.metadata[:facts] || {}
  mc.compound_filter example.example_group.top_level_description
  unless classes.empty? and facts.empty?
    classes.each do |c|
      mc.class_filter c
    end
    facts.each do |f, v|
      mc.fact_filter f, v
    end
  end
  mc
end

def check_spec (example, action, values)
  @spec_mc ||= rpcclient('spec')
  @spec_mc.progress = false
  @spec_mc = apply_filters @spec_mc, example
  passed = []
  failed = []
  @spec_mc.check(:action => action, :values => values).each do |resp|
    if resp[:data][:passed]
      passed << resp[:sender]
    else
      failed << resp[:sender]
    end
  end
  return passed, failed
end

def get_fqdn (example)
  @util_mc ||= rpcclient('rpcutil')
  @util_mc.progress = false
  @util_mc = apply_filters @util_mc, example
  fqdn = []
  @util_mc.get_fact(:fact => 'fqdn').each do |resp|
    fqdn << resp[:data][:value]
  end
  fqdn
end

RSpec.configure do |c|
  c.before :each do
    unless @spec_mc.nil?
      @spec_mc.reset
    end
  end
end
