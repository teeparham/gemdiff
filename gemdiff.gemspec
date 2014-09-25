# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gemdiff/version'

Gem::Specification.new do |spec|
  spec.name          = "gemdiff"
  spec.version       = Gemdiff::VERSION
  spec.authors       = ["Tee Parham"]
  spec.email         = ["tee@neighborland.com"]
  spec.summary       = %q{Find source repositories for ruby gems. Open, compare, and update outdated gem versions}
  spec.description   = %q{Command-line utility to find source repositories for ruby gems, open common github pages, compare gem versions, and simplify gem update workflow in git}
  spec.homepage      = "https://github.com/teeparham/gemdiff"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = %w[gemdiff]
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "octokit", "~> 3.1"
  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "launchy", "~> 2.4"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "minitest", "~> 5.4"
  spec.add_development_dependency "mocha", "~> 1.1"
  spec.add_development_dependency "rake", "~> 10.3"
end
