# frozen_string_literal: true

GEM_ROOT = File.expand_path("..", __dir__)
TEST_ROOT = __dir__
FIXTURES_ROOT = TEST_ROOT + "/fixtures"

require "minitest/autorun"
require "active_support"

$LOAD_PATH << File.expand_path("../lib", __dir__)

require "saga"

lambda do
  def root
    File.expand_path("..", __dir__)
  end

  def load_support
    Dir[File.join(root, "test/support/**/*.rb")].each { |file| require file }
  end

  load_support
end.call

module ActiveSupport
  # Super class of all out test classes
  class TestCase
    include Support::OutputHelpers

    protected

    def fixture_path
      File.expand_path("fixtures", __dir__)
    end
  end
end
