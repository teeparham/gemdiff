# frozen_string_literal: true

require "minitest/autorun"
require "mocha/minitest"
require "gemdiff"

begin
  require "debug" unless ENV["CI"]
rescue LoadError
  # ok
end
