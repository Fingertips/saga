# frozen_string_literal: true

require_relative '../test_helper'

class VerifierEmptyTest < ActiveSupport::TestCase
  setup do
    @document = Saga::Parser.parse(
      File.read(File.expand_path('../cases/empty.txt', __dir__))
    )
    @verifier = Saga::Verifier.new(@document)
  end

  test 'has no output for empty documents' do
    output = collect_stdout { @verifier.run }
    assert_empty(output)
  end
end

class VerifierNoIssuesTest < ActiveSupport::TestCase
  setup do
    @document = Saga::Parser.parse(
      File.read(File.expand_path('../cases/document.txt', __dir__))
    )
    @verifier = Saga::Verifier.new(@document)
  end

  test 'has no output for documents without issues' do
    output = collect_stdout { @verifier.run }
    assert_empty(output)
  end
end

class VerifierDuplicateStoryIdsTest < ActiveSupport::TestCase
  setup do
    @document = Saga::Parser.parse(
      File.read(File.expand_path('../cases/duplicate_story_ids.txt', __dir__))
    )
    @verifier = Saga::Verifier.new(@document)
  end

  test 'prints ids for duplicate stories' do
    output = collect_stdout { @verifier.run }
    assert_equal("* Document has multiple stories with the same id: 1", output)
  end
end

class VerifierDuplicateStoryIdsInAndAcrossSectionsTest < ActiveSupport::TestCase
  setup do
    @document = Saga::Parser.parse(
      File.read(File.expand_path('../cases/duplicate_story_ids_sections.txt', __dir__))
    )
    @verifier = Saga::Verifier.new(@document)
  end

  test 'prints ids for duplicate stories' do
    output = collect_stdout { @verifier.run }
    assert_equal(
      <<~EXPECTED.strip,
        * Sections "Authentication" and "Administration" share story ids: 3
        * Sections "Authorization" and "Administration" share story ids: 2
        * Section "Administration" has multiple stories with the same id: 1
      EXPECTED
      output
    )
  end
end
