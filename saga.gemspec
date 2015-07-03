# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name = "saga"
  spec.version = "0.11.0"
  spec.date = "2015-07-03"
  
  spec.authors = ["Manfred Stienstra"]
  spec.email = "manfred@fngtps.com"
  
  spec.description = "Saga is a tool to convert stories syntax to a nicely formatted document."
  spec.summary = "Saga is a tool to convert stories syntax to a nicely formatted document."
  
  spec.executables = ["saga"]
  spec.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  spec.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION"
  ] + Dir['templates/**/*'] + Dir['lib/**/*.rb'] + Dir['bin/*']
  spec.require_paths = ["lib"]
  spec.rubygems_version = "1.8.11"

  spec.add_runtime_dependency('erubis', '>= 2.6')
  spec.add_runtime_dependency('activesupport', '>= 2.3')
  spec.add_development_dependency('bacon')
  spec.add_development_dependency('mocha-on-bacon')
end