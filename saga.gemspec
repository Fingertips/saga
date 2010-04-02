# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{saga}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Manfred Stienstra"]
  s.date = %q{2010-04-02}
  s.default_executable = %q{saga}
  s.description = %q{Saga is a tool to convert stories syntax to a nicely formatted document.}
  s.email = %q{manfred@fngtps.com}
  s.executables = ["saga"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     ".kick",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/saga",
     "lib/saga.rb",
     "lib/saga/document.rb",
     "lib/saga/formatter.rb",
     "lib/saga/parser.rb",
     "lib/saga/runner.rb",
     "lib/saga/tokenizer.rb",
     "saga.gemspec",
     "templates/default/document.erb",
     "templates/default/helpers.rb",
     "templates/requirements.txt.erb",
     "templates/saga/document.erb",
     "templates/saga/helpers.rb",
     "test/cases/author.txt",
     "test/cases/definition.txt",
     "test/cases/story.txt",
     "test/cases/story_attributes.txt",
     "test/saga_document_spec.rb",
     "test/saga_formatter_spec.rb",
     "test/saga_parser_spec.rb",
     "test/saga_runner_spec.rb",
     "test/saga_tokenizer_spec.rb",
     "test/spec_helper.rb"
  ]
  s.homepage = %q{http://fingertips.github.com}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Saga is a tool to convert stories syntax to a nicely formatted document.}
  s.test_files = [
    "test/saga_document_spec.rb",
     "test/saga_formatter_spec.rb",
     "test/saga_parser_spec.rb",
     "test/saga_runner_spec.rb",
     "test/saga_tokenizer_spec.rb",
     "test/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<erubis>, [">= 2.6"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3"])
      s.add_development_dependency(%q<mocha-on-bacon>, [">= 0"])
    else
      s.add_dependency(%q<erubis>, [">= 2.6"])
      s.add_dependency(%q<activesupport>, [">= 2.3"])
      s.add_dependency(%q<mocha-on-bacon>, [">= 0"])
    end
  else
    s.add_dependency(%q<erubis>, [">= 2.6"])
    s.add_dependency(%q<activesupport>, [">= 2.3"])
    s.add_dependency(%q<mocha-on-bacon>, [">= 0"])
  end
end

