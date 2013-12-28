# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'feedly/version'

Gem::Specification.new do |spec|
  spec.name          = "feedly"
  spec.version       = Feedly::VERSION
  spec.authors       = ["Yoshihiro Kameda"]
  spec.email         = ["kameda.sbng@gmail.com"]
  spec.description   = %q{This gem can access to Feely Cloud API. Supports GETS, POSTS, AUTH apis.}
  spec.summary       = %q{Feedly Cloud API wrapper library.}
  spec.homepage      = "https://github.com/kmdsbng/feedly"
  spec.license       = "Apache2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
