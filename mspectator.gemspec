# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mspectator/version'

Gem::Specification.new do |spec|
  spec.name          = "mspectator"
  spec.version       = MSpectator::VERSION
  spec.authors       = ["Raphaël Pinson"]
  spec.email         = ["raphink@gmail.com"]
  spec.description   = %q{Use RSpec and MCollective to test your fleet}
  spec.summary       = %q{Use RSpec and MCollective to test your fleet}
  spec.homepage      = "https://github.com/raphink/mspectator"
  spec.license       = "GPLv3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mcollective"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
