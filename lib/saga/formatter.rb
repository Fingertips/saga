require 'rubygems'
require 'erubis'

module Saga
  class Formatter
    TEMPLATE_PATH = File.expand_path('../../../templates', __FILE__)
    
    def initialize(document)
      @document = document
    end
    
    def format
      helpers_file = File.join(self.class.template_path, 'default/helpers.rb')
      load helpers_file
      @document.extend(Helpers)
      binding = @document.send(:binding)
      
      template_file = File.join(self.class.template_path, 'default/document.erb')
      template = Erubis::Eruby.new(File.read(template_file))
      template.result(binding)
    end
    
    def self.format(document)
      formatter = new(document)
      formatter.format
    end
    
    def self.template_path
      TEMPLATE_PATH
    end
  end
end