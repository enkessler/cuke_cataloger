# TODO: have better testing so that this can be safely refactored
# rubocop:disable Metrics/AbcSize - Not going to mess with this, given how little testing is present

module CukeCataloger

  # Not a part of the public API. Subject to change at any time.
  class TextReportFormatter

    # Formats validation results into a readable text report
    def format_data(data)
      report_text = "Validation Results\nProblems found: #{data.count}\n\n"


      results_by_category = Hash.new { |hash, key| hash[key] = [] }

      data.each do |result|
        results_by_category[result[:problem]] << result
      end

      results_by_category.each_key do |problem_category|
        report_text << "#{problem_category} problems: #{results_by_category[problem_category].count}\n"
      end

      results_by_category.each_key do |problem_category|
        report_text << "\n\n#{problem_category} problems (#{results_by_category[problem_category].count}):\n"

        results_by_category[problem_category].each do |result|
          report_text << "#{result[:test]}\n"
        end
      end

      report_text
    end

  end
end

# rubocop:enable Metrics/AbcSize
