$:.unshift(File.expand_path('../../../lib', __FILE__))
$:.unshift(File.expand_path('../../../ext', __FILE__))

require 'saga'

parser = Object.new
Saga::Scanner.scan(parser, 'As an admin')