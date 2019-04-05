require 'erb'

module Saga
  class Formatter
    TEMPLATE_PATH = File.expand_path('../../templates', __dir__)

    attr_reader :document
    attr_reader :template_path

    def initialize(document, template_path: nil)
      @document = document
      @template_path ||= template_path || File.join(self.class.template_path, 'default')
    end

    def template
      @template ||= build_template
    end

    def format
      @document.extend(ERB::Util) unless @document.is_a?(ERB::Util)

      if File.exist?(helpers_file)
        @document.instance_eval(File.read(helpers_file))
      end

      template.result(@document._binding)
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

    if RUBY_VERSION < '2.6.0'
      def build_erb
        ERB.new(File.read(template_file), nil, '-')
      end
    else
      def build_erb
        ERB.new(File.read(template_file), trim_mode: '-')
      end
    end

    def build_template
      if File.exist?(template_file)
        build_erb
      else
        raise ArgumentError, "The template at path `#{template_file}' could not be found."
      end
    end

    def helpers_file
      File.join(template_path, 'helpers.rb')
    end

    def template_file
      File.join(template_path, 'document.erb')
    end
  end
end
