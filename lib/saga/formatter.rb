require 'erubis'

module Saga
  class Formatter
    TEMPLATE_PATH = File.expand_path('../../../templates', __FILE__)
    
    def initialize(document, options={})
      @document = document
      @options  = options
      @options[:template] ||= 'default'
    end
    
    def format
      template_path = File.join(self.class.template_path, @options[:template])
      
      helpers_file = File.join(template_path, 'helpers.rb')
      load helpers_file
      @document.extend(Helpers)
      binding = @document.send(:binding)
      
      template_file = File.join(template_path, 'document.erb')
      template = Erubis::Eruby.new(File.read(template_file))
      template.result(binding)
    end
    
    def self.format(document, options={})
      formatter = new(document, options)
      formatter.format
    end
    
    def self.template_path
      TEMPLATE_PATH
    end
  end
end