require 'rake'
require 'rake/rdoctask'

desc "Run all specs by default"
task :default => [:spec]

desc "Run all specs"
task :spec do
  sh 'bacon test/*_spec.rb'
end

namespace :documentation do
  Rake::RDocTask.new(:generate) do |rd|
    rd.main = "README.rdoc"
    rd.rdoc_files.include("README.rdoc", "LICENSE", "bin/**/*.rb", "lib/**/*.rb", "templates/**/*.rb")
    rd.options << "--all" << "--charset" << "utf-8"
  end
end