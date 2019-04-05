# frozen_string_literal: true

require_relative '../test_helper'

class PlanningTest < ActiveSupport::TestCase
  test 'empty planning shows an empty planning message' do
    document = Saga::Document.new
    planning = Saga::Planning.new(document)
    assert_equal 'There are no stories yet.', planning.to_s
  end

  test 'planning for unestimated stories shows a planning' do
    document = Saga::Document.new
    document.stories[''] = [{}, {}, { stories: [{}, {}] }]
    planning = Saga::Planning.new(document)
    assert_equal 'Unestimated   : 5 stories', planning.to_s
  end

  test 'planning for estimated and unestimated stories shows a planning' do
    document = Saga::Document.new
    document.stories[''] = [{}, {}, {}]
    document.stories['Member'] = [{}, { estimate: [6, :hours], stories: [{ estimate: [6, :hours] }] }, {}]
    planning = Saga::Planning.new(document)
    assert_equal(
      "Unplanned     : 12 (2 stories)\n" \
      "------------------------------\n" \
      "Total         : 12 (2 stories)\n" \
      "\n" \
      'Unestimated   : 5 stories',
      planning.to_s
    )
  end

  test 'simple planning shows a planning' do
    document = Saga::Document.new
    document.stories[''] = [{ estimate: [12, :hours] }]
    planning = Saga::Planning.new(document)
    assert_equal(
      "Unplanned     : 12 (one story)\n" \
      "------------------------------\n" \
      'Total         : 12 (one story)',
      planning.to_s
    )
  end

  test 'complicated planning shows a planning' do
    document = Saga::Document.new
    document.stories[''] = [{ estimate: [12, :hours], iteration: 1 }, { estimate: [8, :hours], stories: [{}, {}] }]
    document.stories['Developer'] = [{ estimate: [1, :weeks], iteration: 2, stories: [{ estimate: [2, :hours], iteration: 2 }, { estimate: [1, :hours] }] }, { estimate: [1, :hours], iteration: 2 }]
    document.stories['Writer'] = [{ estimate: [5, :hours], iteration: 1 }, { estimate: [2, :hours], iteration: 3 }]
    planning = Saga::Planning.new(document)
    assert_equal(
      "Unplanned     : 9 (2 stories)\n" \
      "Iteration 1   : 17 (2 stories)\n" \
      "Iteration 2   : 43 (3 stories)\n" \
      "Iteration 3   : 2 (one story)\n" \
      "------------------------------\n" \
      "Total         : 71 (8 stories)\n" \
      "\n" \
      'Unestimated   : 2 stories',
      planning.to_s
    )
  end

  test 'planning with stories with a range estimate shows a planning' do
    document = Saga::Document.new
    document.stories[''] = [{ estimate: ['8-40', :range] }, {}, { stories: [{ estimate: ['1d-5d', :range] }] }]
    planning = Saga::Planning.new(document)
    assert_equal(
      "Unplanned     : 0 (2 stories)\n" \
      "-----------------------------\n" \
      "Total         : 0 (2 stories)\n" \
      "\n" \
      "Unestimated   : 2 stories\n" \
      'Range-estimate: 2 stories',
      planning.to_s
    )
  end
end
