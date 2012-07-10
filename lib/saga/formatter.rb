require 'erubis'

module Saga
  class Formatter
    TEMPLATE_PATH = File.expand_path('../../../templates', __FILE__)
    
    def initialize(document, options={})
      @document = document
      @options  = options
      @options[:template] ||= File.join(self.class.template_path, 'default')
    end
    
    def format
      helpers_file = File.join(@options[:template], 'helpers.rb')
      if File.exist?(helpers_file)
        load helpers_file
        @document.extend(Helpers)
      end
      
      template_file = File.join(@options[:template], 'document.erb')
      if File.exist?(template_file)
        template = Erubis::Eruby.new(File.read(template_file))
        template.result(@document._binding)
      else
        raise ArgumentError, "The template at path `#{template_file}' could not be found."
      end
    end
    
    def self.format(document, options={})
      formatter = new(document, options)
      formatter.format
    end
    
    def self.template_path
      TEMPLATE_PATH
    end

    def self.saga_format(document)
      format(document, :template => File.join(template_path, 'saga'))
    end
  end
end
