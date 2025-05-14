# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tinplate/version'

Gem::Specification.new do |spec|
  spec.name          = "tinplate"
  spec.version       = Tinplate::VERSION
  spec.authors       = ["Aaron Klaassen"]
  spec.email         = ["aaron@unsplash.com"]

  spec.summary       = %q{A wrapper around the TinEye API.}
  spec.homepage      = "https://github.com/unsplash/tinplate"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 0.9.2"

  spec.add_development_dependency "bundler", ">= 2.2.10"
  spec.add_development_dependency "rake",    ">= 12.3.3"
  spec.add_development_dependency "rspec",   "~> 3.4.0"
  spec.add_development_dependency "pry"
end
