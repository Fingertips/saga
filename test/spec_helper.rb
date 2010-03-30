begin
  require 'rubygems'
rescue LoadError
end

require 'mocha-on-bacon'

$:.unshift(File.expand_path('../../lib', __FILE__))
