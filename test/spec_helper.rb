begin
  require 'rubygems'
rescue LoadError
end

require 'bacon'
require "mocha/standalone"
require "mocha/object"

class Bacon::Context
  include Mocha::Standalone
  
  alias it_without_mocha it
  def it(description)
    it_without_mocha(description) do
      mocha_setup
      yield
      Bacon::Counter[:requirements] += Mocha::Mockery.instance.mocks.length
      mocha_verify
      mocha_teardown
    end
  end
end

$:.unshift(File.expand_path('../../lib', __FILE__))
$:.unshift(File.expand_path('../../ext', __FILE__))

require 'saga'

$:.unshift(File.expand_path('../ext', __FILE__))

