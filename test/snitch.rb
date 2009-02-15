# Class designed to be used to see what messages an object receives
class Snitch
  def method_missing(m, *a)
    puts "[INVOKED]: #{m}(#{a.inspect})"
  end
end