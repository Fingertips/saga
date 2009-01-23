begin
  require 'rubygems'
rescue LoadError
end

require 'bacon'
require 'mocha'

$:.unshift(File.expand_path('../ext', __FILE__))