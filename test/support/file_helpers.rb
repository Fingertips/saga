# frozen_string_literal: true

module Support
  module FileHelpers
    def fixture_path
      File.expand_path("../fixtures", __dir__)
    end

    def cases_path
      File.expand_path("../cases", __dir__)
    end

    def case_path(name)
      File.join(cases_path, "#{name}.txt")
    end

    def case_contents(name)
      File.read(case_path(name))
    end
  end
end
