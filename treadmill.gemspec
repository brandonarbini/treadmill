# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'treadmill/version'

Gem::Specification.new do |spec|
  spec.name          = "treadmill"
  spec.version       = Treadmill::VERSION
  spec.authors       = ["Justin Greer", "Brandon Arbini"]
  spec.email         = ["jgreer@justingreer.com", "b@arbini.com"]
  spec.description   = %q{Bluetooth interaction with LifeSpan treadmills}
  spec.summary       = %q{This gem can retrieve information from and control LifeSpan treadmills}
  spec.homepage      = "https://github.com/brandonarbini/treadmill"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "thor", "~> 0.18.1"
end
