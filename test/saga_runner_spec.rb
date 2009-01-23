require File.expand_path('../spec_helper', __FILE__)

require 'saga/runner'

describe "A Runner" do
  it "should show a help text when invoked without a command and options" do
    @runner = Saga::Runner.new([])
    @runner.expects(:puts).with(@runner.parser.to_s)
    @runner.run
  end
  
  it "should show a help test when the -h option is used" do
    @runner = Saga::Runner.new(%w(-h))
    @runner.expects(:puts).at_least(1)
    @runner.stubs(:exit)
    @runner.run
  end
end