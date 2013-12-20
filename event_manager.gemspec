# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_manager/version'

Gem::Specification.new do |spec|
  spec.name          = "event_manager"
  spec.version       = EventManager::VERSION
  spec.authors       = ["Ryan Mathews", "Timothy Barnes"]
  spec.email         = ["ryan@ryanjm.com"]
  spec.description   = %q{Repeating schedule manager Rails.}
  spec.summary       = %q{Repeating schedule manager Rails.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency 'rails', '~> 3.0'
end
