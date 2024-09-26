# frozen_string_literal: true

source "https://rubygems.org"

gem "minitest", "~> 5.21"
gem "mocha", "~> 2.0"
gem "rake", "~> 13.0"

unless ENV["CI"]
  gem "pry-byebug"
  gem "rubocop", "~> 1.66"
  gem "rubocop-packaging", "~> 0.5"
  gem "rubocop-performance", "~> 1.22"
  gem "rubocop-rake", "~> 0.6"
end

gemspec
