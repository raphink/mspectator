RSpec::Matchers.define :have_package do |package|
  match do |filter|
    mc = rpcclient('spec')
    mc.progress = false
    mc = apply_filters mc, example, filter
    @passed = []
    @failed = []
    mc.check(:action => 'installed', :values => package).each do |resp|
      if resp[:data][:passed]
        @passed << resp[:sender]
      else
        @failed << resp[:sender]
      end
    end
    @failed.empty?
  end

  failure_message_for_should do |actual|
    "expected that all hosts would have the #{expected} package, but found hosts without it:\n  #{@failed.join('  \n')}"
  end

  failure_message_for_should_not do |actual|
    "expected that no hosts would have the #{expected} package, but found hosts with it:\n  #{@passed.join('  \n')}"
  end
end
