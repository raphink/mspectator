RSpec::Matchers.define :have_certificate do
  match do |filter|
    discovered = get_fqdn(example, filter)
    puppetca_mc = rpcclient('puppetca')
    puppetca_mc.progress = false
    # TODO: use hash for requests and signed
    # so we can tell where a certificate was found
    requests = []
    signed = []
    puppetca_mc.list.each do |resp|
      requests << resp[:data][:requests]
      signed << resp[:data][:signed]
    end
    requests.flatten!
    signed.flatten!
    @passed = []
    @failed = []
    discovered.each do |c|
      if !@signed and requests.include? c
        @passed << c
      elsif signed.include? c
        @passed << c
      else
        @failed << c
      end
    end
    @failed.empty?
  end

  failure_message_for_should do |actual|
    "expected that all hosts would have a valid #{@signed_msg}certificate, but found hosts without one: #{@failed.join(', ')}"
  end

  failure_message_for_should_not do |actual|
    "expected that no hosts would have a valid #{@signed_msg}certificate, but found hosts with one: #{@passed.join(', ')}"
  end

  chain :signed do
    @signed = true
    @signed_msg = 'signed '
  end
end
