require 'erb'

module Saga
  class Formatter
    TEMPLATE_PATH = File.expand_path('../../../templates', __FILE__)

    attr_reader :document
    attr_reader :template_path

    def initialize(document, template_path: nil)
      @document = document
      @template_path ||= template_path || File.join(self.class.template_path, 'default')
    end

    def format
      @document.extend(ERB::Util)
      if File.exist?(helpers_file)
        load helpers_file
        @document.extend(Helpers)
      end

      if File.exist?(template_file)
        template = ERB.new(File.read(template_file), nil, '-')
        template.result(@document._binding)
      else
        raise ArgumentError, "The template at path `#{template_file}' could not be found."
      end
    end

    def self.format(document, **kwargs)
      formatter = new(document, **kwargs)
      formatter.format
    end

    def self.template_path
      TEMPLATE_PATH
    end

    def self.saga_format(document)
      format(document, template_path: File.join(template_path, 'saga'))
    end

    private

    def helpers_file
      File.join(template_path, 'helpers.rb')
    end

    def template_file
      File.join(template_path, 'document.erb')
    end
  end
end
