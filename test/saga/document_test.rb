# frozen_string_literal: true

require_relative '../test_helper'

class DocumentTest < ActiveSupport::TestCase
  test "responds to accessors" do
    document = Saga::Document.new
    [:title, :introduction, :authors, :stories, :definitions].each do |method|
      assert document.respond_to?(method)
    end
  end

  test "stores stories in the order it receives them" do
    document = Saga::Document.new
    sections = %w(First Second Third Fourth Fifth)
    sections.each do |section|
      document.stories[section] = {}
    end
    assert_equal sections, document.stories.keys
  end

  test "stores definitions in the order it receives them" do
    document = Saga::Document.new
    sections = %w(First Second Third Fourth Fifth)
    sections.each do |section|
      document.definitions[section] = {}
    end
    assert_equal sections, document.definitions.keys
  end

  test "flattens stories" do
    document = Saga::Document.new
    document.stories[''] = [
      { estimate: ['8-40', :range] },
      {},
      {
        stories: [
          { estimate: ['1d-5d', :range] }
        ]
      }
    ]
    document.stories['Help'] = [{}]
    assert_equal(
      [
        { estimate: ['8-40', :range] },
        {},
        {},
        { estimate: ['1d-5d', :range] },
        {}
      ],
      document.stories_as_flat_list
    )
  end

  test "returns the number of stories as its length" do
    document = Saga::Document.new
    assert_equal 0, document.length

    document.stories[''] = [{}, {}]
    assert_equal 2, document.length

    document.stories['Non-functional'] = [{}]
    assert_equal 3, document.length
  end

  test "knows whether the document does or does not have stories" do
    document = Saga::Document.new
    assert document.empty?

    document.stories[''] = [{},{}]
    assert_not document.empty?
  end

  test "returns a list of used IDs" do
    document = Saga::Document.new
    assert_equal [], document.used_ids

    document.stories[''] = []
    document.stories[''] << { id: 2 }
    assert_equal [2], document.used_ids

    document.stories['Non-functional'] = []
    document.stories['Non-functional'] << { id: 12 }
    assert_equal [2, 12], document.used_ids

    document.stories['Non-functional'] << { id: 3 }
    assert_equal [2, 12, 3], document.used_ids

    document.stories[''][0][:stories] = [
      {}, {id: 14}, {}, {id: 5}
    ]
    assert_equal [2, 14, 5, 12, 3], document.used_ids
  end

  test "returns a list of unused IDs" do
    document = Saga::Document.new
    assert_equal [], document.unused_ids(0)
    assert_equal [1,2,3], document.unused_ids(3)
    assert_equal [1,2,3,4], document.unused_ids(4)

    document.stories[''] = []
    document.stories[''] << { id: 2 }
    document.stories[''] << { id: 4 }
    document.stories[''] << { id: 5 }
    document.stories[''] << { id: 6 }
    document.stories[''] << { id: 100 }

    assert_equal [], document.unused_ids(0)
    assert_equal [1], document.unused_ids(1)
    assert_equal [1,3], document.unused_ids(2)
    assert_equal [1,3,7], document.unused_ids(3)
    assert_equal [1,3,7,8], document.unused_ids(4)
  end

  test "autofills ids" do
    document = Saga::Document.new
    document.autofill_ids

    document.stories[''] = []
    document.stories[''] << { description: 'First story'}
    document.stories[''] << { description: 'Second story', stories: [
      { description: 'First nested story' }, { id: 15, description: 'Second nested story'}
    ] }

    document.stories['Non-functional'] = []
    document.stories['Non-functional'] << { id: 1, description: 'Third story' }

    document.stories['Developer'] = []
    document.stories['Developer'] << { description: 'Fourth story' }
    document.stories['Developer'] << { id: 3, description: 'Fifth story' }

    document.autofill_ids
    assert_equal [2, 4], document.stories[''].map { |story| story[:id] }
    assert_equal [5, 15], document.stories[''][1][:stories].map { |story| story[:id] }
    assert_equal [1], document.stories['Non-functional'].map { |story| story[:id] }
    assert_equal [6, 3], document.stories['Developer'].map { |story| story[:id] }
  end
end

class DocumentAnimalFormattingTest < ActiveSupport::TestCase
  test "recognizes stories without the standard formatting" do
    document = Saga::Parser.parse(
      File.read(
        File.expand_path('../../cases/animal_formatting.txt', __FILE__)
      )
    )
    assert_equal 2, document.stories['Tractor integration'].length
  end
end
