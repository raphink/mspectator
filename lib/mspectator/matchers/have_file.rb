RSpec::Matchers.define :have_file do |file|
  match do
    @passed, @failed = check_spec(example, 'file', file)
    @failed.empty?
  end

  failure_message_for_should do |actual|
    "expected that all hosts would have the #{expected} file, but found hosts without it: #{@failed.join(', ')}"
  end

  failure_message_for_should_not do |actual|
    "expected that no hosts would have the #{expected} file, but found hosts with it: #{@passed.join(', ')}"
  end
end
