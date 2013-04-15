RSpec::Matchers.define :find_nodes do |number|
  match do
    @agent ||= 'rpcutil'
    mc = rpcclient(@agent)
    mc.progress = false
    mc = apply_filters mc, example
    @size = mc.discover.size
    if @compare == :or_less
      @size <= number
    elsif @compare == :or_more
      @size >= number
    else
      @size == number
    end
  end

  chain :or_less do
    @compare = :or_less
    @compare_msg = ' or less'
  end

  chain :or_more do
    @compare = :or_more
    @compare_msg = ' or more'
  end

  chain :with_agent do |agent|
    @agent = agent
  end

  failure_message_for_should do |actual|
    "expected to find #{expected} nodes#{@compare_msg} using agent '#{@agent}', but found #{@size} instead."
  end

  failure_message_for_should_not do |actual|
    "expected not to find #{expected} nodes#{@compare_msg} using agent '#{@agent}', but found #{@size} instead."
  end
end
