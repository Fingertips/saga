begin
  require 'rubygems'
rescue LoadError
end

# Mocha really wants to add MiniTest or TestUnit extensions, we don't need those
ENV['MOCHA_OPTIONS'] = 'skip_integration'

require 'bacon'
require 'mocha-on-bacon'

Bacon.extend Bacon::TapOutput
$:.unshift(File.expand_path('../../lib', __FILE__))
require 'saga'
