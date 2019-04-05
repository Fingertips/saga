# frozen_string_literal: true

require File.expand_path('lib/saga/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'saga'
  spec.version = Saga::VERSION
  spec.authors = [
    'Manfred Stienstra'
  ]
  spec.email = [
    'manfred@fngtps.com'
  ]
  spec.summary = <<-SUMMARY
  Saga is a tool to convert stories syntax to a nicely formatted document.
  SUMMARY
  spec.description = <<-DESCRIPTION
  Saga reads its own story format and formats to other output formats using
  templates.
  DESCRIPTION
  spec.homepage = 'https://github.com/Fingertips/saga'
  spec.license = 'MIT'

  spec.executables << 'saga'
  spec.files = Dir.glob('lib/**/*') + [
    'LICENSE',
    'README.rdoc'
  ]
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 5'
  spec.add_development_dependency 'rake'
end
