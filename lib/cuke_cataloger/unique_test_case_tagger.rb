require 'cucumber_analytics'


class UniqueTestCaseTagger

  def initialize
    @file_line_increases = Hash.new(0)
  end

  def tag_tests(feature_directory, tag_prefix)
    warn("This script will potentially rewrite all of your feature files. Please be patient and remember to tip your source control system.")

    # Object collection
    world = CucumberAnalytics::World
    directory = CucumberAnalytics::Directory.new(feature_directory)
    tests = world.tests_in(directory)


    # For this example, I am using a simple counter and prefix pattern to determine
    # uniqueness. YMMV.

    @tag_prefix = tag_prefix
    @tag_pattern = Regexp.new("#{@tag_prefix}\\d+")

    matching_tags = world.tags_in(directory).select { |tag| tag =~ @tag_pattern }
    @last_index_used = matching_tags.collect { |tag| tag[/\d+/] }.sort.last.to_i


    # Analysis and output
    tests.each do |test|
      case
        when test.class.to_s =~ /Scenario/
          tag_scenario(test)
        when test.class.to_s =~ /Outline/
          tag_outline(test)
        else
          raise("Unknown test type: #{test.class.to_s}")
      end
    end
  end


  private


  def tag_scenario(test)
    apply_tag_if_needed(test)
  end

  def tag_outline(test)
    apply_tag_if_needed(test)

    sub_id = 0
    test.examples.each do |example|
      update_rows_if_needed(example, sub_id)

      # For the purposes of this example, it is assumed that any new, untagged
      # example groups are added at the end of existing example groups. This allows
      # the additional complexity of determining which sub-ids are already being
      # used to be avoided.

      sub_id += example.rows.count
    end
  end

  def apply_tag_if_needed(test)
    unless has_id_tag?(test)
      tag = "#{@tag_prefix}#{@last_index_used + 1}"
      @last_index_used += 1

      tag_test(test, tag)
    end
  end

  def has_id_tag?(test)
    test.tags.any? { |tag| tag =~ @tag_pattern }
  end

  def tag_test(test, tag, padding_string = '  ')
    feature_file = get_type_of_thing_for_thing(:feature_file, test)
    file_path = feature_file.path

    index_adjustment = @file_line_increases[file_path]
    tag_index = (test.source_line - 1) + index_adjustment

    file_lines = []
    File.open(file_path, 'r') { |file| file_lines = file.readlines }
    file_lines.insert(tag_index, "#{padding_string}#{tag}\n")

    File.open(file_path, 'w') { |file| file.print file_lines.join }
    @file_line_increases[file_path] += 1
  end

  def update_rows_if_needed(example, sub_id)

    # For the purposes of this example, it is assumed that there are no incomplete
    # example groups. Such a case could be handled but the additional complexity
    # is outside of the scope of what is needed here to get the gist of it across.

    unless has_id_parameter?(example)
      test = get_type_of_thing_for_thing(:test, example)
      feature_file = get_type_of_thing_for_thing(:feature_file, test)
      file_path = feature_file.path

      if has_id_tag?(test)
        tag_index = tag_id(test)[/\d+/]
      else
        tag_index = @last_index_used
      end

      index_adjustment = @file_line_increases[file_path]
      parameter_line_index = (example.row_elements.first.source_line - 1) + index_adjustment

      file_lines = []
      File.open(file_path, 'r') { |file| file_lines = file.readlines }

      update_parameter_row(file_lines, parameter_line_index)

      example.row_elements[1..(example.row_elements.count - 1)].each do |row|
        sub_id += 1
        row_id = "#{tag_index}-#{sub_id}".ljust(12)

        index_adjustment = @file_line_increases[file_path]
        row_line_index = (row.source_line - 1) + index_adjustment

        update_value_row(file_lines, row_line_index, row_id)
      end

      File.open(file_path, 'w') { |file| file.print file_lines.join }
    end
  end

  def tag_id(test)
    test.tags.select { |tag| tag =~ @tag_pattern }.first
  end

  def has_id_parameter?(example)
    example.parameters.any? { |parameter| parameter == 'test_case_id' }
  end

  # Some methods have more thought put into their names than others
  def get_type_of_thing_for_thing(ancestor_type, thing)
    ancestor_type = {:example => CucumberAnalytics::Example,
                     :feature_file => CucumberAnalytics::FeatureFile,
                     :test => CucumberAnalytics::TestElement
    }[ancestor_type]

    until thing.is_a?(ancestor_type)
      thing = thing.parent_element
    end

    thing
  end

  def update_parameter_row(file_lines, line_index)
    prepend_row!(file_lines, line_index, '    | test_case_id ')
  end

  def update_value_row(file_lines, line_index, row_id)
    prepend_row!(file_lines, line_index, "    | #{row_id} ")
  end

  def prepend_row!(file_lines, line_index, string)
    old_row = file_lines[line_index]
    new_row = string + old_row.lstrip
    file_lines[line_index] = new_row
  end

end
