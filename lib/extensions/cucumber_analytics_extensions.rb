module CukeModeler
  module Parsing

    class << self

      def parse_text(source_text, file_name = nil)
        raise(ArgumentError, "Cannot parse #{source_text.class} objects. Strings only.") unless source_text.is_a?(String)

        file_name ||= 'fake_file.txt'

        io = StringIO.new
        formatter = Gherkin::Formatter::JSONFormatter.new(io)
        parser = Gherkin::Parser::Parser.new(formatter)
        begin
          parser.parse(source_text, file_name, 0)

          formatter.done
        rescue => e
          raise("Error encountered while parsing file #{file_name}: #{e.message}")
        end
        MultiJson.load(io.string)
      end

    end

  end
end


module CukeModeler
  class FeatureFile


    private


    def parse_file(file_to_parse)
      source_text = IO.read(file_to_parse)

      Parsing::parse_text(source_text, file_to_parse)
    end

  end
end
