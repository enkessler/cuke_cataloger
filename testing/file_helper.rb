require 'tempfile'


module CukeCataloger
  module FileHelper

    def self.create_feature_file(options = {})
      options[:text] ||= 'Feature:'
      options[:name] ||= 'test_file'

      create_file(:text => options[:text], :name => options[:name], :extension => '.feature', :directory => options[:directory])
    end

    def self.create_file(options = {})
      options[:text] ||= ''
      options[:name] ||= 'test_file'
      options[:extension] ||= '.txt'
      options[:directory] ||= Dir::tmpdir

      temp_file = Tempfile.new([options[:name], options[:extension]], options[:directory])
      File.open(temp_file.path, 'w') { |file| file.write(options[:text]) }

      temp_file
    end

  end
end
