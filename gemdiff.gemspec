# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gemdiff/version'

Gem::Specification.new do |spec|
  spec.name          = "gemdiff"
  spec.version       = Gemdiff::VERSION
  spec.authors       = ["Tee Parham"]
  spec.email         = ["tee@neighborland.com"]
  spec.summary       = %q{Compare gem versions}
  spec.description   = %q{Command-line utility to find source repository URLs related to ruby gems and compare gem versions}
  spec.homepage      = "https://github.com/teeparham/gemdiff"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = %w[gemdiff]
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "bundler", "~> 1.5"
  spec.add_dependency "octokit", "~> 2.7"
  spec.add_dependency "thor", "~> 0.18"
  spec.add_dependency "launchy", "~> 2.4"

  spec.add_development_dependency "minitest", "~> 5.3"
  spec.add_development_dependency "mocha", "~> 1.0"
  spec.add_development_dependency "rake", "~> 10.1"
end
