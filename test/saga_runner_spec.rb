require File.expand_path('../spec_helper', __FILE__)
require 'singleton'

describe "A Runner" do
  extend OutputHelper
  
  it "shows a help text when invoked without a command and options" do
    runner = Saga::Runner.new([])
    collect_stdout do
      runner.run
    end.should == runner.parser.to_s
  end
  
  it "shows a help test when the -h option is used" do
    runner = Saga::Runner.new(%w(-h))
    runner.stubs(:exit)
    collect_stdout do
      runner.run
    end.should == runner.parser.to_s*2 # Because we stub exit it runs twice ):
  end
  
  it "generates a requirements stub to can get started" do
    Saga::Runner.stubs(:author).returns({:name => "Manfred Stienstra"})
    runner = Saga::Runner.new(%w(new))
    output = collect_stdout do
      runner.run
    end
    output.should.include('Requirements Title')
    output.should.include('- Manfred Stienstra')
  end
  
  it "knows information about the user currently logged in to the system" do
    author = Saga::Runner.author
    author[:name].should.not.be.nil
  end
  
  it "converts the provided filename" do
    runner = Saga::Runner.new(%w(requirements.txt))
    runner.expects(:convert).with(File.expand_path('requirements.txt'), {}).returns('output')
    collect_stdout do
      runner.run
    end.should == "output\n"
  end
  
  it "converts the provided filename when the convert command is given" do
    runner = Saga::Runner.new(%w(convert requirements.txt))
    runner.expects(:convert).with(File.expand_path('requirements.txt'), {}).returns('output')
    collect_stdout do
      runner.run
    end.should == "output\n"
  end
  
  it "converts the provided filename with an external template" do
    Saga::Parser.stubs(:parse)
    File.stubs(:read)
    Saga::Formatter.expects(:format).with do |_, options|
      options[:template].should == File.expand_path('path/to/a/template')
    end
    runner = Saga::Runner.new(%W(convert --template path/to/a/template requirements.txt))
    collect_stdout { runner.run }
  end
  
  it "inspects the parsed document" do
    runner = Saga::Runner.new(%w(inspect requirements.txt))
    runner.expects(:write_parsed_document).with(File.expand_path('requirements.txt'))
    runner.run
  end
  
  it "autofills the parsed document" do
    runner = Saga::Runner.new(%w(autofill requirements.txt))
    runner.expects(:autofill).with(File.expand_path('requirements.txt')).returns('output')
    collect_stdout do
      runner.run
    end.should == "output\n"
  end
  
  it "shows an overview of the time planned in the different iterations" do
    runner = Saga::Runner.new(%w(planning requirements.txt))
    runner.expects(:planning).with(File.expand_path('requirements.txt')).returns('output')
    collect_stdout do
      runner.run
    end.should == "output\n"
  end
  
  it "copies the default template to the specified path" do
    begin
      destination = "/tmp/saga-template-dir"
      Saga::Runner.new(%W(template #{destination})).run
      File.read(File.join(destination, 'helpers.rb')).should ==
        File.read(File.join(Saga::Formatter.template_path, 'default/helpers.rb'))
      File.read(File.join(destination, 'document.erb')).should ==
        File.read(File.join(Saga::Formatter.template_path, 'default/document.erb'))
    ensure
      FileUtils.rm_rf(destination)
    end
  end
  
  it "complains when tryin to create a template at an existing path" do
    begin
      destination = "/tmp/saga-template-dir"
      FileUtils.mkdir_p(destination)
      runner = Saga::Runner.new(%W(template #{destination}))
      collect_stdout do
        runner.run
      end.should == "The directory `#{destination}' already exists!\n"
      File.should.not.exist File.join(destination, 'helpers.rb')
      File.should.not.exist File.join(destination, 'document.erb')
    ensure
      FileUtils.rm_rf(destination)
    end
  end
end
