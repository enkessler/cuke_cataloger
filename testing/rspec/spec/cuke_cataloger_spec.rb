require "#{File.dirname(__FILE__)}/spec_helper"


describe 'the gem' do

  here = File.dirname(__FILE__)

  let(:gemspec) { eval(File.read "#{here}/../../../cuke_cataloger.gemspec") }

  it 'has an executable' do
    expect(gemspec.executables).to include('cuke_cataloger')
  end

  it 'makes the executable available after installation' do
    old_gemfile = ENV['BUNDLE_GEMFILE']

    begin
      puts "overwriting file: #{"#{@lib_directory}/cuke_cataloger/version.rb"}"
      File.write("#{@lib_directory}/cuke_cataloger/version.rb", "module CukeCataloger\nVERSION = '0.0.0-test'\nend")


      output = `gem build cuke_cataloger.gemspec`
      puts "executable test output: #{output}"
      output = `gem install cuke_cataloger-0.0.0.pre.test.gem`
      puts "executable test output: #{output}"


      ENV['BUNDLE_GEMFILE'] = 'testing/gemfiles/executable.gemfile'
      output = `bundle exec cuke_cataloger`
      puts "executable test output: #{output}"

    ensure
      ENV['BUNDLE_GEMFILE'] = old_gemfile
      # `gem uninstall cuke_cataloger -v 0.0.0-test`
      `git checkout HEAD -- #{@lib_directory}/cuke_cataloger/version.rb`
    end

    pending
  end

end
