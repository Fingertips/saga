# frozen_string_literal: true

require_relative '../test_helper'

class RunnerTest < ActiveSupport::TestCase
  test "shows a help text when invoked without a command and options" do
    runner = Saga::Runner.new([])
    expected = runner.parser.to_s
    assert_equal(
      expected,
      collect_stdout { runner.run }
    )
  end

  test "shows a help test when the -h option is used" do
    runner = Saga::Runner.new(%w(-h))
    expected = runner.parser.to_s
    assert_equal(
      expected,
      collect_stdout { runner.run }
    )
  end

  test "generates a requirements stub to can get started" do
    runner = shape(
      Saga::Runner,
      %w(new),
      author: { name: "Manfred Stienstra" }
    )
    output = collect_stdout { runner.run }
    assert output.include?('Requirements Title')
    assert output.include?('- Manfred Stienstra')
  end

  test "knows information about the user currently logged in to the system" do
    author = Saga::Runner.new([]).author
    refute_nil author[:name]
  end

  test "converts the provided filename" do
    runner = shape(
      Saga::Runner,
      %w(requirements.txt),
      convert: 'output'
    )
    assert_equal(
      "output",
      collect_stdout { runner.run }
    )
  end

  test "converts the provided filename when the convert command is given" do
    runner = shape(
      Saga::Runner,
      %w(convert requirements.txt),
      convert: 'output'
    )
    assert_equal(
      "output",
      collect_stdout { runner.run }
    )
  end

  test "converts the provided filename with an external template" do
    runner = Saga::Runner.new(%W(convert --template path/to/a/template requirements.txt))
    assert_equal(
      {
        template_path: File.expand_path('path/to/a/template')
      },
      runner.convert_options
    )
  end

  test "inspects the parsed document" do
    runner = Saga::Runner.new(%W(inspect #{case_path('document')}))
    output = collect_stdout { runner.run }
    assert output.include?(':name')
  end

  test "autofills the parsed document" do
    runner = Saga::Runner.new(%W(autofill #{case_path('document')}))
    output = collect_stdout { runner.run }
    assert output.include?('#3 todo')
  end

  test "shows an overview of the time planned in the different iterations" do
    runner = Saga::Runner.new(%W(planning #{case_path('document')}))
    output = collect_stdout { runner.run }
    assert_equal "Unestimated   : 3 stories", output
  end

  test "copies the default template to the specified path" do
    destination = File.join(Dir.tmpdir, 'templates')
    begin
      Saga::Runner.new(%W(template #{destination})).run
      %w(helpers.rb document.erb).each do |name|
        assert_equal(
          File.read(File.join(Saga::Formatter.template_path, 'default', name)),
          File.read(File.join(destination, name))
        )
      end
    ensure
      FileUtils.rm_rf(destination)
    end
  end

  test "complains when tryin to create a template at an existing path" do
    destination = File.join(Dir.tmpdir, 'templates')
    begin
      FileUtils.mkdir_p(destination)
      runner = Saga::Runner.new(%W(template #{destination}))
      output = collect_stdout { runner.run}
      assert_equal(
        "The directory `#{destination}' already exists!",
        output
      )
      %w(helpers.rb document.erb).each do |name|
        assert_not File.exist?(File.join(destination, name))
      end
    ensure
      FileUtils.rm_rf(destination)
    end
  end
end
