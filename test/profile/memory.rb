$:.unshift(File.expand_path('../../../lib', __FILE__))
$:.unshift(File.expand_path('../../../ext', __FILE__))

require 'saga'


class Snitch
  def method_missing(m, *a)
    puts "[INVOKED]: #{m}(#{a.inspect})"
  end
end

Saga::Scanner.scan(Snitch.new, "As a developer I would like to have written a site which is compliant with XHTML and CSS standards so that as many people as possible can access the site and view it as intended.\n")