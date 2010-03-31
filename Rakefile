require 'rake'
require 'rake/rdoctask'

desc "Run all specs by default"
task :default => [:spec]

desc "Run all specs"
task :spec do
  Dir[File.dirname(__FILE__) + '/test/**/*_spec.rb'].each do |file|
    load file
  end
end

namespace :documentation do
  Rake::RDocTask.new(:generate) do |rd|
    rd.main = "README.rdoc"
    rd.rdoc_files.include("README.rdoc", "LICENSE", "bin/**/*.rb", "lib/**/*.rb", "templates/**/*.rb")
    rd.options << "--all" << "--charset" << "utf-8"
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "saga"
    s.summary = s.description = "Saga is a tool to convert stories syntax to a nicely formatted document."
    s.homepage = "http://fingertips.github.com"
    s.email = "manfred@fngtps.com"
    s.authors = ["Manfred Stienstra"]
    s.add_dependency('erubis', '>= 2.6')
    s.add_dependency('activesupport', '>= 2.3')
    s.add_development_dependency('mocha-on-bacon')
  end
rescue LoadError
end