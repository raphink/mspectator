RSpec::Matchers.define :pass_puppet_spec do
  match do
    spec_mc = rpcclient('spec')
    spec_mc.progress = false
    # TODO: use hashes to grab output
    @passed = []
    @failed = []
    spec_mc.run.each do |resp|
      if resp[:data][:passed]
        @passed << resp[:sender]
      else
        @failed << resp[:sender]
      end
    end
    @failed.empty?
  end

  failure_message_for_should do |actual|
    "expected that all hosts would pass tests, the following didn't: #{@failed.join(', ')}"
  end

  failure_message_for_should_not do |actual|
    "expected that no hosts would pass tests, the following did: #{@passed.join(', ')}"
  end
end
