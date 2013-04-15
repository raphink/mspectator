RSpec::Matchers.define :have_service do |service|
  match do
    @filters ||= {}
    if @filters.fetch(:enable, false) == true
      @action = 'enabled'
    elsif @filters.fetch(:ensure, false) == 'running'
      @action = 'running'
    else
      @action = 'running'
    end
    @passed, @failed = check_spec(example, @action, service)
    @failed.empty?
  end

  failure_message_for_should do |actual|
    "expected that all hosts would have the #{expected} service #{@action}, but found hosts without it: #{@failed.join(', ')}"
  end

  failure_message_for_should_not do |actual|
    "expected that no hosts would have the #{expected} service #{@action}, but found hosts with it: #{@passed.join(', ')}"
  end

  chain :with do |filters|
    @filters = filters
  end
end

