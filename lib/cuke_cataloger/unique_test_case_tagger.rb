module CukeCataloger
  class UniqueTestCaseTagger

    SUB_ID_PATTERN = /^\d+\-\d+$/
    SUB_ID_MATCH_PATTERN = /^\d+\-(\d+)$/


    attr_accessor :tag_location


    def initialize
      @file_line_increases = Hash.new(0)
      @tag_location = :adjacent
    end

    def tag_tests(feature_directory, tag_prefix, explicit_indexes = {})
      warn("This script will potentially rewrite all of your feature files. Please be patient and remember to tip your source control system.")

      @known_id_tags = {}

      set_id_tag(tag_prefix)
      set_test_suite_model(feature_directory)

      @start_indexes = merge_indexes(default_start_indexes(determine_known_ids(feature_directory, tag_prefix)), explicit_indexes)
      @next_index = @start_indexes[:primary]

      # Analysis and output
      @tests.each do |test|
        case
          when test.is_a?(CukeModeler::Scenario)
            process_scenario(test)
          when test.is_a?(CukeModeler::Outline)
            process_outline(test)
          else
            raise("Unknown test type: #{test.class.to_s}")
        end
      end
    end

    def scan_for_tagged_tests(feature_directory, tag_prefix)
      @results = []
      @known_id_tags = {}

      set_id_tag(tag_prefix)
      set_test_suite_model(feature_directory)

      @tests.each do |test|
        add_to_results(test) if has_id_tag?(test)

        if test.is_a?(CukeModeler::Outline)
          test.examples.each do |example|
            if has_id_parameter?(example)
              example_rows_for(example).each do |row|
                add_to_results(row) if has_row_id?(row)
              end
            end
          end
        end
      end

      @results
    end

    def validate_test_ids(feature_directory, tag_prefix)
      @results = []
      @known_id_tags = {}

      set_id_tag(tag_prefix)
      set_test_suite_model(feature_directory)

      @features.each { |feature| validate_feature(feature) }
      @tests.each { |test| validate_test(test) }

      @results
    end

    def determine_known_ids(feature_directory, tag_prefix)
      known_ids = []

      found_tagged_objects = scan_for_tagged_tests(feature_directory, tag_prefix).collect { |result| result[:object] }

      found_tagged_objects.each do |element|
        if element.is_a?(CukeModeler::Row)
          row_id = row_id_for(element)
          known_ids << row_id if well_formed_sub_id?(row_id)
        else
          known_ids << test_id_for(element)
        end
      end

      known_ids
    end


    private


    def set_id_tag(tag_prefix)
      @tag_prefix = tag_prefix
      #todo -should probably escape these characters
      @tag_pattern = Regexp.new("#{@tag_prefix}\\d+")
    end

    def set_test_suite_model(feature_directory)
      @directory = CukeModeler::Directory.new(feature_directory)
      @model_repo = CQL::Repository.new(@directory)

      @tests = @model_repo.query do
        select :self
        from scenarios, outlines
      end.collect { |result| result[:self] }

      @features = @model_repo.query do
        select :self
        from features
      end.collect { |result| result[:self] }
    end

    def validate_feature(feature)
      check_for_feature_level_test_tag(feature)
    end

    def validate_test(test)
      check_for_missing_test_tag(test)
      check_for_multiple_test_id_tags(test)
      check_for_duplicated_test_id_tags(test)

      if test.is_a?(CukeModeler::Outline)
        check_for_missing_id_columns(test)
        check_for_missing_row_tags(test)
        check_for_duplicated_row_tags(test)
        check_for_mismatched_row_tags(test)
        check_for_malformed_row_tags(test)
      end
    end

    def check_for_feature_level_test_tag(feature)
      add_to_results(feature, :feature_test_tag) if has_id_tag?(feature)
    end

    def check_for_duplicated_test_id_tags(test)
      @existing_tags ||= @model_repo.query do
        select tags
        from features, scenarios, outlines, examples
      end.collect { |result| result['tags'] }.flatten

      test_id_tag = static_id_tag_for(test)

      matching_tags = @existing_tags.select { |tag| tag == test_id_tag }

      add_to_results(test, :duplicate_id_tag) if matching_tags.count > 1
    end

    def check_for_multiple_test_id_tags(test)
      id_tags_found = test.tags.select { |tag| tag =~ @tag_pattern }

      add_to_results(test, :multiple_tags) if id_tags_found.count > 1
    end

    def check_for_missing_test_tag(test)
      add_to_results(test, :missing_tag) unless has_id_tag?(test)
    end

    def check_for_missing_id_columns(test)
      test.examples.each do |example|
        add_to_results(example, :missing_id_column) unless has_id_column?(example)
      end
    end

    def check_for_duplicated_row_tags(test)
      validate_rows(test, :duplicate_row_id, false, :has_duplicate_row_id?)
    end

    def check_for_missing_row_tags(test)
      validate_rows(test, :missing_row_id, true, :has_row_id?)
    end

    def check_for_mismatched_row_tags(test)
      validate_rows(test, :mismatched_row_id, true, :has_matching_id?)
    end

    def check_for_malformed_row_tags(test)
      test.examples.each do |example|
        if has_id_column?(example)
          example_rows_for(example).each do |row|
            add_to_results(row, :malformed_sub_id) if (has_row_id?(row) && !well_formed_sub_id?(row_id_for(row)))
          end
        end
      end
    end

    def validate_rows(test, rule, desired, row_check)
      test.examples.each do |example|
        if has_id_column?(example)
          example_rows_for(example).each do |row|
            if desired
              add_to_results(row, rule) unless self.send(row_check, row)
            else
              add_to_results(row, rule) if self.send(row_check, row)
            end
          end
        end
      end
    end

    def process_scenario(test)
      apply_tag_if_needed(test)
    end

    def process_outline(test)
      apply_tag_if_needed(test)
      update_parameters_if_needed(test)
      update_rows_if_needed(test, determine_next_sub_id(test))
    end

    def apply_tag_if_needed(test)
      unless has_id_tag?(test)
        tag = "#{@tag_prefix}#{@next_index}"
        @next_index += 1

        tag_test(test, tag, (' ' * determine_test_indentation(test)))
      end
    end

    def has_id_tag?(test)
      !!fast_id_tag_for(test)
    end

    def has_id_column?(example)
      example.parameters.any? { |param| param =~ /test_case_id/ }
    end

    def row_id_for(row)
      id_index = determine_row_id_cell_index(row)

      id_index && row.cells[id_index] != '' ? row.cells[id_index] : nil
    end

    def has_row_id?(row)
      !!row_id_for(row)
    end

    def well_formed_sub_id?(id)
      !!(id =~ SUB_ID_PATTERN)
    end

    def has_matching_id?(row)
      row_id = row_id_for(row)

      # A lack of id counts as 'matching'
      return true if row_id.nil?

      parent_tag = static_id_tag_for(row.get_ancestor(:test))

      if parent_tag
        parent_id = parent_tag.sub(@tag_prefix, '')

        row_id =~ /#{parent_id}-/
      else
        row_id.nil?
      end
    end

    def has_duplicate_row_id?(row)
      row_id = row_id_for(row)

      return false unless row_id && well_formed_sub_id?(row_id)

      existing_ids = determine_used_sub_ids(row.get_ancestor(:test))
      matching_ids = existing_ids.select { |id| id == row_id[/\d+$/] }

      matching_ids.count > 1
    end

    def determine_next_sub_id(test)
      parent = test_id_for(test)
      explicit_index = @start_indexes[:sub][parent]

      explicit_index ? explicit_index : 1
    end

    def determine_used_sub_ids(test)
      ids = test.examples.collect do |example|
        if has_id_parameter?(example)
          example_rows_for(example).collect do |row|
            row_id_for(row)
          end
        else
          []
        end
      end

      ids.flatten!
      ids.delete_if { |id| !id.to_s.match(SUB_ID_PATTERN) }

      ids.collect! { |id| id.match(SUB_ID_MATCH_PATTERN)[1] }

      ids
    end

    def determine_row_id_cell_index(row)
      row.get_ancestor(:example).parameters.index { |param| param =~ /test_case_id/ }
    end

    def tag_test(test, tag, padding_string = '  ')
      feature_file = test.get_ancestor(:feature_file)
      file_path = feature_file.path

      index_adjustment = @file_line_increases[file_path]
      tag_index = source_line_to_use(test) + index_adjustment

      file_lines = File.readlines(file_path)
      file_lines.insert(tag_index, "#{padding_string}#{tag}\n")

      File.open(file_path, 'wb') { |file| file.print file_lines.join }
      @file_line_increases[file_path] += 1
      test.tags << tag
    end

    def update_parameters_if_needed(test)
      feature_file = test.get_ancestor(:feature_file)
      file_path = feature_file.path
      index_adjustment = @file_line_increases[file_path]

      test.examples.each do |example|
        unless has_id_parameter?(example)
          parameter_line_index = (example.row_elements.first.source_line - 1) + index_adjustment

          file_lines = File.readlines(file_path)

          new_parameter = 'test_case_id'.ljust(parameter_spacing(example))
          update_parameter_row(file_lines, parameter_line_index, new_parameter)
          File.open(file_path, 'wb') { |file| file.print file_lines.join }
        end
      end
    end

    def update_rows_if_needed(test, sub_id)
      feature_file = test.get_ancestor(:feature_file)
      file_path = feature_file.path
      index_adjustment = @file_line_increases[file_path]

      tag_index = fast_id_tag_for(test)[/\d+/]

      file_lines = File.readlines(file_path)

      test.examples.each do |example|
        example.row_elements[1..(example.row_elements.count - 1)].each do |row|
          unless has_row_id?(row)
            row_id = "#{tag_index}-#{sub_id}".ljust(parameter_spacing(example))

            row_line_index = (row.source_line - 1) + index_adjustment

            update_value_row(file_lines, row_line_index, row, row_id)
            sub_id += 1
          end
        end

        File.open(file_path, 'wb') { |file| file.print file_lines.join }
      end
    end


    # Slowest way to get the id tag. Will check the object every time.
    def current_id_tag_for(thing)
      id_tag_for(thing)
    end

    # Faster way to get the id tag. Will skip checking the object if an id for it is already known.
    def fast_id_tag_for(thing)
      @known_id_tags ||= {}

      id = @known_id_tags[thing.object_id]

      unless id
        id = current_id_tag_for(thing)
        @known_id_tags[thing.object_id] = id
      end

      id
    end

    # Fastest way to get the id tag. Will skip checking the object if it has been checked before, even if no id was found.
    def static_id_tag_for(thing)
      @known_id_tags ||= {}
      id_key = thing.object_id

      return @known_id_tags[id_key] if @known_id_tags.has_key?(id_key)

      id = current_id_tag_for(thing)
      @known_id_tags[id_key] = id

      id
    end

    def id_tag_for(thing)
      thing.tags.select { |tag| tag =~ @tag_pattern }.first
    end

    def test_id_for(test)
      #todo - should probably be escaping these in case regex characters used in prefix...
      fast_id_tag_for(test).match(/#{@tag_prefix}(.*)/)[1]
    end

    def has_id_parameter?(example)
      #todo - make the id column name configurable
      example.parameters.any? { |parameter| parameter == 'test_case_id' }
    end

    def update_parameter_row(file_lines, line_index, parameter)
      append_row!(file_lines, line_index, " #{parameter} |")
    end

    def update_value_row(file_lines, line_index, row, row_id)
      case
        when needs_adding?(row)
          append_row!(file_lines, line_index, " #{row_id} |")
        when needs_filled_in?(row)
          fill_in_row(file_lines, line_index, row, row_id)
        else
          raise("Don't know how to update row")
      end
    end

    def needs_adding?(row)
      !has_id_parameter?(row.get_ancestor(:example))
    end

    def needs_filled_in?(row)
      has_id_parameter?(row.get_ancestor(:example))
    end

    def replace_row!(file_lines, line_index, new_line)
      file_lines[line_index] = new_line
    end

    def prepend_row!(file_lines, line_index, string)
      old_row = file_lines[line_index]
      new_row = string + old_row.lstrip
      file_lines[line_index] = new_row
    end

    def append_row!(file_lines, line_index, string)
      old_row = file_lines[line_index]
      trailing_bits = old_row[/\s*$/]
      new_row = old_row.rstrip + string + trailing_bits

      file_lines[line_index] = new_row
    end

    def example_rows_for(example)
      rows = example.row_elements.dup
      rows.shift

      rows
    end

    def add_to_results(item, issue = nil)
      result = {:test => "#{item.get_ancestor(:feature_file).path}:#{item.source_line}", :object => item}
      result.merge!({:problem => issue}) if issue

      @results << result
    end

    def default_start_indexes(known_ids)
      primary_ids = known_ids.select { |id| id =~ /^\d+$/ }
      sub_ids = known_ids.select { |id| id =~ /^\d+-\d+$/ }

      max_primary_id = primary_ids.collect { |id| id.to_i }.max || 0
      default_indexes = {:primary => max_primary_id + 1,
                         :sub => {}}

      sub_primaries = sub_ids.collect { |sub_id| sub_id[/^\d+/] }

      sub_primaries.each do |primary|
        default_indexes[:sub][primary] = sub_ids.select { |sub_id| sub_id[/^\d+/] == primary }.collect { |sub_id| sub_id[/\d+$/].to_i }.max + 1
      end

      default_indexes
    end

    def merge_indexes(set1, set2)
      set1.merge(set2) { |key, set1_value, set2_value|
        key == :sub ? set1_value.merge(set2_value) : set2_value
      }
    end

    def parameter_spacing(example)
      test = example.get_ancestor(:test)
      test_id = fast_id_tag_for(test)[/\d+$/]
      row_count = test.examples.reduce(0) { |sum, example| sum += example.rows.count }

      max_id_length = test_id.length + 1 + row_count.to_s.length
      param_length = 'test_case_id'.length

      [param_length, max_id_length].max
    end

    def determine_test_indentation(test)
      #todo - replace with 'get_most_recent_file_text'
      feature_file = test.get_ancestor(:feature_file)
      file_path = feature_file.path

      index_adjustment = @file_line_increases[file_path]
      test_index = (test.source_line - 1) + index_adjustment

      file_lines = File.readlines(file_path)
      indentation = file_lines[test_index][/^\s*/].length

      indentation
    end

    def fill_in_row(file_lines, line_index, row, row_id)
      old_row = file_lines[line_index]
      sections = file_lines[line_index].split('|', -1)

      replacement_index = determine_row_id_cell_index(row)
      sections[replacement_index + 1] = " #{row_id} "

      new_row = sections.join('|')

      replace_row!(file_lines, line_index, new_row)
    end

    def source_line_to_use(test)
      case @tag_location
        when :above
          determine_highest_tag_line(test)
        when :below
          determine_lowest_tag_line(test)
        when :adjacent
          adjacent_tag_line(test)
        else
          raise(ArgumentError, "Don't know where #{@tag_location} is.")
      end
    end

    def determine_highest_tag_line(test)
      return adjacent_tag_line(test) if test.tags.empty?

      test.tag_elements.collect { |tag_element| tag_element.source_line }.min - 1
    end

    def determine_lowest_tag_line(test)
      return adjacent_tag_line(test) if test.tags.empty?

      test.tag_elements.collect { |tag_element| tag_element.source_line }.max
    end

    def adjacent_tag_line(test)
      (test.source_line - 1)
    end

  end
end
