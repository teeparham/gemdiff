# frozen_string_literal: true

require "minitest/autorun"
require "mocha/minitest"
require "gemdiff"

begin
  require "debug"
rescue LoadError
  # ok
end
