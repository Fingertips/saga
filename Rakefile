require 'rake/rdoctask'

desc "Run all specs by default"
task :default => [:compile, :spec]

desc "Compile everything that needs compiling"
task :compile => "ext:compile"

desc "Run all specs"
task :spec do
  require 'rubygems'
  require 'mocha'
  require 'bacon'

  Bacon.extend Bacon::SpecDoxOutput
  Bacon.summary_on_exit

  Dir[File.dirname(__FILE__) + '/test/**/*_spec.rb'].each do |file|
    load file
  end
end

task :clean do
  crap = "*.{bundle,so,o,obj,log,png,dot}"
  ["*.gem", "ext/**/#{crap}", "ext/saga/scanner.c", "ext/**/Makefile"].each do |glob|
    Dir.glob(glob).each do |file|
      rm(file)
    end
  end
end

namespace :ext do
  desc "Compile the Ruby extension"
  task :compile
end

namespace :ext do
  extension = 'saga'
  ext = "ext/#{extension}"
  ext_so = "#{ext}/#{extension}.#{Config::CONFIG['DLEXT']}"
  ext_files = FileList[
    "#{ext}/*.c",
    "#{ext}/*.h",
    "#{ext}/*.rl",
    "#{ext}/*.dot",
    "#{ext}/*.png",
    "#{ext}/extconfig.rb",
    "#{ext}/Makefile"
  ]
  
  task :compile => extension do
    unless File.exist?(File.expand_path('../ext/saga/scanner.bundle', __FILE__)) or
           File.exist?(File.expand_path('../ext/saga/scanner.so', __FILE__))
      $stderr.puts("Failed to build #{extension}.")
      exit(1)
    end
  end
  
  file "#{ext}/scanner.c"  do
    sh %{cd ext/saga; ragel scanner.rl -o scanner.c}
  end
  
  file "#{ext}/scanner.dot" do
    sh %{cd ext/saga; ragel -V scanner.rl > scanner.dot}
  end
  
  file "#{ext}/scanner.png" => "#{ext}/scanner.dot" do
    sh %{cd ext/saga; neato -o scanner.png -T png scanner.dot}
  end
  
  file "#{ext}/Makefile" => "#{ext}/scanner.c" do
    Dir.chdir(ext) { ruby "extconfig.rb" }
  end
  
  desc "Shows the a state diagram of the scanner"
  task :visualize => "#{ext}/scanner.png" do
    sh %{open #{ext}/scanner.png}
  end
  
  desc "Builds just the #{extension} extension"
  task extension.to_sym => ["#{ext}/Makefile", ext_so ]
  
  file ext_so => ext_files do
    Dir.chdir(ext) do
      sh(PLATFORM =~ /win32/ ? 'nmake' : 'make') do |ok, res|
        if !ok
          require "fileutils"
          FileUtils.rm Dir.glob('*.{so,o,dll,bundle}')
        end
      end
    end
  end
end

namespace :profile do
  desc "Profile memory"
  task :memory => :compile do
    sh 'valgrind --tool=memcheck --leak-check=yes --num-callers=10 --track-fds=yes ruby test/profile/memory.rb'
  end
end

namespace :gem do
  desc "Build the gem"
  task :build do
    sh 'gem build saga.gemspec'
  end
  
  task :install => :build do
    sh 'sudo gem install saga-*.gem'
  end
end

namespace :documentation do
  Rake::RDocTask.new(:generate) do |rd|
    rd.main = "README"
    rd.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
    rd.options << "--all" << "--charset" << "utf-8"
  end
end