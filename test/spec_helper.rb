begin
  require 'rubygems'
rescue LoadError
end

require 'bacon'
require 'mocha-on-bacon'

Bacon.extend Bacon::TapOutput
$:.unshift(File.expand_path('../../lib', __FILE__))
require 'saga'
