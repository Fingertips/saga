$:.unshift(File.expand_path('../../../lib', __FILE__))
$:.unshift(File.expand_path('../../../ext', __FILE__))

require 'saga'

class Parser
  def handle_role(role)
  end
end

Saga::Scanner.scan(Parser.new, "As an admin\n")