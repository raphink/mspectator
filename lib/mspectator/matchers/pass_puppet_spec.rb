RSpec::Matchers.define :pass_puppet_spec do
  match do
    spec_mc = filtered_mc('spec')
    @passed = []
    @failed = {}
    spec_mc.run.each do |resp|
      if resp[:data][:passed]
        @passed << resp[:sender]
      else
        @failed[resp[:sender]] = resp[:data][:output]
      end
    end
    @failed.empty?
  end

  failure_message_for_should do |actual|
    text = "expected that all hosts would pass tests, the following didn't:\n"
    @failed.each do |h, o|
      text += "#{h}:\n #{o}"
    end
    text
  end

  failure_message_for_should_not do |actual|
    "expected that no hosts would pass tests, the following did: #{@passed.join(', ')}"
  end
end
