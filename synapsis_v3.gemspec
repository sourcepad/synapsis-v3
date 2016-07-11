# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synapsis_v3/version'

Gem::Specification.new do |spec|
  spec.name          = "synapsis_v3"
  spec.version       = SynapsisV3::VERSION
  spec.authors       = ["Daryll Santos"]
  spec.email         = ["daryll.santos@gmail.com"]

  spec.summary       = %q{Ruby interface to the SynapsePayments API (v3)}
  spec.description   = %q{Ruby interface to the SynapsePayments API (v3)}
  spec.homepage      = "http://github.com/sourcepad/synapsis_v3"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "faraday", "0.9.1"
  spec.add_runtime_dependency "mime-types", "2.6.1"
  spec.add_runtime_dependency "faraday-detailed_logger", "2.0.0"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "faker", "~> 1.4.3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "codeclimate-test-reporter"
end
