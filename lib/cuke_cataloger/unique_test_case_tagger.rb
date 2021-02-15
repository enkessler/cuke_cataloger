module CukeCataloger

  # A tagger that handles test case cataloging.

  class UniqueTestCaseTagger

    # The pattern of a sub id
    SUB_ID_PATTERN = /^\d+\-\d+$/  # Not a part of the public API. Subject to change at any time.

    # The pattern of a sub id, with id capture
    SUB_ID_MATCH_PATTERN = /^\d+\-(\d+)$/   # Not a part of the public API. Subject to change at any time.


    # Where the id tag should be placed, relative to the other tags on the test
    attr_accessor :tag_location

    # Creates a new UniqueTestCaseTagger object
    def initialize
      @file_line_increases = Hash.new(0)
      @tag_location = :adjacent
    end

    # Adds id tags based on *tag_prefix* to the tests found in *feature_directory*
    def tag_tests(feature_directory, tag_prefix = '@test_case_', explicit_indexes = {}, tag_rows = true, id_column_name = 'test_case_id')
      warn("This script will potentially rewrite all of your feature files. Please be patient and remember to tip your source control system.")

      @known_id_tags = {}

      set_id_tag(tag_prefix)
      set_test_suite_model(feature_directory)

      @start_indexes = merge_indexes(default_start_indexes(determine_known_ids(feature_directory, tag_prefix, id_column_name)), explicit_indexes)
      @next_index = @start_indexes[:primary]

      # Analysis and output
      @tests.each do |test|
        case
          when test.is_a?(CukeModeler::Scenario)
            process_scenario(test)
          when test.is_a?(CukeModeler::Outline)
            process_outline(test, tag_rows, id_column_name)
          else
            raise("Unknown test type: #{test.class.to_s}")
        end
      end
    end

    # Finds existing id tags and their associated tests in *feature_directory* based on *tag_prefix*
    def scan_for_tagged_tests(feature_directory, tag_prefix = '@test_case_', id_column_name = 'test_case_id')
      @results = []
      @known_id_tags = {}

      set_id_tag(tag_prefix)
      set_test_suite_model(feature_directory)

      @tests.each do |test|
        add_to_results(test) if has_id_tag?(test)

        if test.is_a?(CukeModeler::Outline)
          test.examples.each do |example|
            if has_id_parameter?(example, id_column_name)
              example_rows_for(example).each do |row|
                add_to_results(row) if has_row_id?(row, id_column_name)
              end
            end
          end
        end
      end

      @results
    end

    # Checks for cataloging problems in *feature_directory* based on *tag_prefix*
    def validate_test_ids(feature_directory, tag_prefix = '@test_case_', tag_rows = true, id_column_name = 'test_case_id')
      @results = []
      @known_id_tags = {}

      set_id_tag(tag_prefix)
      set_test_suite_model(feature_directory)

      @features.each { |feature| validate_feature(feature) }
      @tests.each { |test| validate_test(test, tag_rows, id_column_name) }

      @results
    end

    # Finds existing id tags in *feature_directory* based on *tag_prefix*
    def determine_known_ids(feature_directory, tag_prefix = '@test_case_', id_column_name = 'test_case_id')
      known_ids = []

      found_tagged_objects = scan_for_tagged_tests(feature_directory, tag_prefix, id_column_name).collect { |result| result[:object] }

      found_tagged_objects.each do |element|
        if element.is_a?(CukeModeler::Row)
          row_id = row_id_for(element, id_column_name)
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
      @tag_pattern = Regexp.new("^#{@tag_prefix}\\d+$")
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

    def validate_test(test, tag_rows, id_column_name)
      check_for_missing_test_tag(test)
      check_for_multiple_test_id_tags(test)
      check_for_duplicated_test_id_tags(test)

      if test.is_a?(CukeModeler::Outline)
        check_for_missing_id_columns(test, id_column_name) if tag_rows
        check_for_missing_row_tags(test, id_column_name) if tag_rows
        check_for_duplicated_row_tags(test, id_column_name) if tag_rows
        check_for_mismatched_row_tags(test, id_column_name) if tag_rows
        check_for_malformed_row_tags(test, id_column_name) if tag_rows
      end
    end

    def check_for_feature_level_test_tag(feature)
      add_to_results(feature, :feature_test_tag) if has_id_tag?(feature)
    end

    def check_for_duplicated_test_id_tags(test)
      unless @existing_tags
        @existing_tags = @model_repo.query do
          select tags
          from features, scenarios, outlines, examples
        end.collect { |result| result['tags'] }.flatten

        @existing_tags.map!(&:name)
      end

      test_id_tag = static_id_tag_for(test)

      matching_tags = @existing_tags.select { |tag| tag == test_id_tag }

      add_to_results(test, :duplicate_id_tag) if matching_tags.count > 1
    end

    def check_for_multiple_test_id_tags(test)
      tags = test.tags.map(&:name)

      id_tags_found = tags.select { |tag| tag =~ @tag_pattern }

      add_to_results(test, :multiple_tags) if id_tags_found.count > 1
    end

    def check_for_missing_test_tag(test)
      add_to_results(test, :missing_tag) unless has_id_tag?(test)
    end

    def check_for_missing_id_columns(test, id_column_name)
      test.examples.each do |example|
        add_to_results(example, :missing_id_column) unless has_id_column?(example, id_column_name)
      end
    end

    def check_for_duplicated_row_tags(test, id_column_name)
      validate_rows(test, :duplicate_row_id, false, :has_duplicate_row_id?, id_column_name)
    end

    def check_for_missing_row_tags(test, id_column_name)
      validate_rows(test, :missing_row_id, true, :has_row_id?, id_column_name)
    end

    def check_for_mismatched_row_tags(test, id_column_name)
      validate_rows(test, :mismatched_row_id, true, :has_matching_id?, id_column_name)
    end

    def check_for_malformed_row_tags(test, id_column_name)
      test.examples.each do |example|
        if has_id_column?(example, id_column_name)
          example_rows_for(example).each do |row|
            add_to_results(row, :malformed_sub_id) if (has_row_id?(row, id_column_name) && !well_formed_sub_id?(row_id_for(row, id_column_name)))
          end
        end
      end
    end

    # Checks the rows of the given test for the given problem
    def validate_rows(test, rule, desired, row_check, id_column_name)
      test.examples.each do |example|
        if has_id_column?(example, id_column_name)
          example_rows_for(example).each do |row|
            if desired
              add_to_results(row, rule) unless self.send(row_check, row, id_column_name)
            else
              add_to_results(row, rule) if self.send(row_check, row, id_column_name)
            end
          end
        end
      end
    end

    def process_scenario(test)
      apply_tag_if_needed(test)
    end

    def process_outline(test, tag_rows, id_column_name)
      apply_tag_if_needed(test)
      if tag_rows
        update_parameters_if_needed(test, id_column_name)
        update_rows_if_needed(test, determine_next_sub_id(test), id_column_name)
      end
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

    def has_id_column?(example, id_column_name)
      example.parameters.any? { |param| param == id_column_name }
    end

    def row_id_for(row, id_column_name)
      id_index = determine_row_id_cell_index(row, id_column_name)

      if id_index
        cell_value = row.cells[id_index].value

        cell_value != '' ? cell_value : nil
      end
    end

    def has_row_id?(row, id_column_name)
      !!row_id_for(row, id_column_name)
    end

    def well_formed_sub_id?(id)
      !!(id =~ SUB_ID_PATTERN)
    end

    def has_matching_id?(row, id_column_name)
      row_id = row_id_for(row, id_column_name)

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

    def has_duplicate_row_id?(row, id_column_name)
      row_id = row_id_for(row, id_column_name)

      return false unless row_id && well_formed_sub_id?(row_id)

      existing_ids = determine_used_sub_ids(row.get_ancestor(:test), id_column_name)
      matching_ids = existing_ids.select { |id| id == row_id[/\d+$/] }

      matching_ids.count > 1
    end

    def determine_next_sub_id(test)
      parent = test_id_for(test)
      explicit_index = @start_indexes[:sub][parent]

      explicit_index ? explicit_index : 1
    end

    def determine_used_sub_ids(test, id_column_name)
      ids = test.examples.collect do |example|
        if has_id_parameter?(example, id_column_name)
          example_rows_for(example).collect do |row|
            row_id_for(row, id_column_name)
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

    def determine_row_id_cell_index(row, id_column_name)
      row.get_ancestor(:example).parameters.index { |param| param =~ /#{id_column_name}/ }
    end

    def tag_test(test, tag, padding_string = '  ')
      feature_file = test.get_ancestor(:feature_file)
      file_path = feature_file.path

      index_adjustment = @file_line_increases[file_path]
      tag_index = source_line_to_use(test) + index_adjustment

      file_lines = File.readlines(file_path)
      file_lines.insert(tag_index, "#{padding_string}#{tag}\n")

      File.open(file_path, 'w') { |file| file.print file_lines.join }
      @file_line_increases[file_path] += 1

      new_tag = CukeModeler::Tag.new
      new_tag.name = tag
      test.tags << new_tag
    end

    def update_parameters_if_needed(test, id_column_name)
      feature_file = test.get_ancestor(:feature_file)
      file_path = feature_file.path
      index_adjustment = @file_line_increases[file_path]

      test.examples.each do |example|
        unless has_id_parameter?(example, id_column_name)
          parameter_line_index = (example.rows.first.source_line - 1) + index_adjustment

          file_lines = File.readlines(file_path)

          new_parameter = id_column_name.ljust(parameter_spacing(example, id_column_name))
          update_parameter_row(file_lines, parameter_line_index, new_parameter)
          File.open(file_path, 'w') { |file| file.print file_lines.join }
        end
      end
    end

    def update_rows_if_needed(test, sub_id, id_column_name)
      feature_file = test.get_ancestor(:feature_file)
      file_path = feature_file.path
      index_adjustment = @file_line_increases[file_path]

      tag_index = fast_id_tag_for(test)[/\d+/]

      file_lines = File.readlines(file_path)

      test.examples.each do |example|
        example.rows[1..(example.rows.count - 1)].each do |row|
          unless has_row_id?(row, id_column_name)
            row_id = "#{tag_index}-#{sub_id}".ljust(parameter_spacing(example, id_column_name))

            row_line_index = (row.source_line - 1) + index_adjustment

            update_value_row(file_lines, row_line_index, row, row_id, id_column_name)
            sub_id += 1
          end
        end

        File.open(file_path, 'w') { |file| file.print file_lines.join }
      end
    end

    # Slowest way to get the id tag. Will check the object every time.
    def current_id_tag_for(thing)
      tags = thing.tags
      id_tag = tags.detect { |tag| tag.name =~ @tag_pattern }

      return unless id_tag

      id_tag.name
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

    def test_id_for(test)
      #todo - should probably be escaping these in case regex characters used in prefix...
      fast_id_tag_for(test).match(/#{@tag_prefix}(.*)/)[1]
    end

    def has_id_parameter?(example, id_column_name)
      example.parameters.any? { |parameter| parameter == id_column_name }
    end

    # Adds an id column to the given parameter row
    def update_parameter_row(file_lines, line_index, parameter)
      append_row!(file_lines, line_index, " #{parameter} |")
    end

    # Adds an id to the given value row
    def update_value_row(file_lines, line_index, row, row_id, id_column_name)
      case
        when needs_adding?(row, id_column_name)
          append_row!(file_lines, line_index, " #{row_id} |")
        when needs_filled_in?(row, id_column_name)
          fill_in_row(file_lines, line_index, row, row_id, id_column_name)
        else
          raise("Don't know how to update row")
      end
    end

    def needs_adding?(row, id_column_name)
      !has_id_parameter?(row.get_ancestor(:example), id_column_name)
    end

    def needs_filled_in?(row, id_column_name)
      has_id_parameter?(row.get_ancestor(:example), id_column_name)
    end

    # Replaces the indicated line of text with the provided line of tet
    def replace_row!(file_lines, line_index, new_line)
      file_lines[line_index] = new_line
    end

    # Adds text to the beginning of the given line (with whitespace loss)
    def prepend_row!(file_lines, line_index, string)
      old_row = file_lines[line_index]
      new_row = string + old_row.lstrip
      file_lines[line_index] = new_row
    end

    # Adds text to the end of the given line (with whitespace loss)
    def append_row!(file_lines, line_index, string)
      old_row = file_lines[line_index]
      trailing_bits = old_row[/\s*$/]
      new_row = old_row.rstrip + string + trailing_bits

      file_lines[line_index] = new_row
    end

    def example_rows_for(example)
      rows = example.rows.dup
      rows.shift

      rows
    end

    def add_to_results(item, issue = nil)
      result = { :test => "#{item.get_ancestor(:feature_file).path}:#{item.source_line}", :object => item }
      result.merge!({ :problem => issue }) if issue

      @results << result
    end

    def default_start_indexes(known_ids)
      primary_ids = known_ids.select { |id| id =~ /^\d+$/ }
      sub_ids = known_ids.select { |id| id =~ /^\d+-\d+$/ }

      max_primary_id = primary_ids.collect { |id| id.to_i }.max || 0
      default_indexes = { :primary => max_primary_id + 1,
                          :sub => {} }

      sub_primaries = sub_ids.collect { |sub_id| sub_id[/^\d+/] }

      sub_primaries.each do |primary|
        default_indexes[:sub][primary] = sub_ids.select { |sub_id| sub_id[/^\d+/] == primary }.collect { |sub_id| sub_id[/\d+$/].to_i }.max + 1
      end

      default_indexes
    end

    # Merges the given index sets (of the shape {:primary => Integer, :sub => Hash}) into a new one
    def merge_indexes(set1, set2)
      set1.merge(set2) { |key, set1_value, set2_value|
        key == :sub ? set1_value.merge(set2_value) : set2_value
      }
    end

    def parameter_spacing(example, id_column_name)
      test = example.get_ancestor(:test)
      test_id = fast_id_tag_for(test)[/\d+$/]
      row_count = test.examples.reduce(0) { |sum, example| sum += example.rows.count }

      max_id_length = test_id.length + 1 + row_count.to_s.length
      param_length = id_column_name.length

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

    # Adds an id to the given value row (which has a column for an id but no value for it)
    def fill_in_row(file_lines, line_index, row, row_id, id_column_name)
      sections = file_lines[line_index].split('|', -1)

      replacement_index = determine_row_id_cell_index(row, id_column_name)
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

      test.tags.map(&:source_line).min - 1
    end

    def determine_lowest_tag_line(test)
      return adjacent_tag_line(test) if test.tags.empty?

      test.tags.map(&:source_line).max
    end

    def adjacent_tag_line(test)
      (test.source_line - 1)
    end

    def cuke_modeler?(*versions)
      versions.include?(cuke_modeler_major_version)
    end

    def cuke_modeler_major_version
      Gem.loaded_specs['cuke_modeler'].version.version.match(/^(\d+)\./)[1].to_i
    end

  end
end
