require File.expand_path('../spec_helper', __FILE__)
require 'singleton'

module OutputHelper
  class Collector
    attr_reader :written
    def initialize
      @written = []
    end
    
    def write(string)
      @written << string
    end
  end
  
  def collect_stdout(&block)
    collector = Collector.new
    stdout = $stdout
    $stdout = collector
    begin
      block.call
    ensure
      $stdout = stdout
    end
    collector.written.join
  end
end

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
    runner.expects(:convert).with(File.expand_path('requirements.txt')).returns('output')
    collect_stdout do
      runner.run
    end.should == "output\n"
  end
  
  it "converts the provided filename when the convert command is given" do
    runner = Saga::Runner.new(%w(convert requirements.txt))
    runner.expects(:convert).with(File.expand_path('requirements.txt')).returns('output')
    collect_stdout do
      runner.run
    end.should == "output\n"
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
end