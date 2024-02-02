# frozen_string_literal: true

require "./lib/gemdiff/version"

Gem::Specification.new do |spec|
  spec.name          = "gemdiff"
  spec.version       = Gemdiff::VERSION
  spec.authors       = ["Tee Parham"]
  spec.email         = ["parhameter@gmail.com"]
  spec.summary       = "Find source repositories for ruby gems. Open, compare, and update outdated gem versions"
  spec.description   = "Command-line utility to find source repositories for ruby gems, open common GitHub pages, " \
                       "compare gem versions, and simplify gem update workflow in git."
  spec.homepage      = "https://github.com/teeparham/gemdiff"
  spec.license       = "MIT"

  spec.files         = Dir["LICENSE.txt", "README.md", "lib/**/*"]
  spec.executables   = %w[gemdiff]
  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "launchy", "~> 2.4"
  spec.add_dependency "octokit", "~> 4.0"
  spec.add_dependency "thor", "~> 1.0"

  spec.add_development_dependency "minitest", "~> 5.21"
  spec.add_development_dependency "mocha", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
