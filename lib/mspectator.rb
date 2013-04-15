require 'mspectator/matchers'
require 'mspectator/example'

RSpec.configure do |c|
  c.include(MSpectator::ExampleGroup)
end
