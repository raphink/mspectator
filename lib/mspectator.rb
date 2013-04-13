require 'mspectator/matchers'

require 'mcollective'
include ::MCollective::RPC

def apply_filters (mc, example, filter)
  classes = example.metadata[:classes] || []
  facts = example.metadata[:facts] || {}
  if classes.empty? and facts.empty?
    mc.compound_filter filter
  else
    classes.each do |c|
      mc.class_filter c
    end
    facts.each do |f, v|
      mc.fact_filter f, v
    end
  end
  mc
end

def check_spec (example, filter, action, values)
  mc = rpcclient('spec')
  mc.progress = false
  mc = apply_filters mc, example, filter
  passed = []
  failed = []
  mc.check(:action => action, :values => values).each do |resp|
    if resp[:data][:passed]
      passed << resp[:sender]
    else
      failed << resp[:sender]
    end
  end
  return passed, failed
end
