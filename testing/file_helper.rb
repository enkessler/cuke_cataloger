require 'tmpdir'


module CukeCataloger
  module FileHelper

    class << self

      def create_feature_file(options = {})
        options[:text] ||= 'Feature:'
        options[:name] ||= 'test_file'

        create_file(:text => options[:text], :name => options[:name], :extension => '.feature', :directory => options[:directory])
      end

      def create_file(options = {})
        options[:text] ||= ''
        options[:name] ||= 'test_file'
        options[:extension] ||= '.txt'
        options[:directory] ||= create_directory

        file_path = "#{options[:directory]}/#{options[:name]}#{options[:extension]}"
        File.open(file_path, 'w') { |file| file.write(options[:text]) }

        file_path
      end

      def created_directories
        @created_directories ||= []
      end

      def create_directory
        new_dir = Dir::mktmpdir
        created_directories << new_dir

        new_dir
      end

    end

  end
end
