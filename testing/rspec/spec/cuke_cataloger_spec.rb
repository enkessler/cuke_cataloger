require "#{__dir__}/spec_helper"
require 'rubygems/mock_gem_ui'


describe 'the gem' do

  before(:all) do
    # Doing this as a one time hook instead of using `let` in order to reduce I/O time during testing.
    @gemspec = eval(File.read "#{__dir__}/../../../cuke_cataloger.gemspec")
  end


  it 'has an executable' do
    expect(@gemspec.executables).to include('cuke_cataloger')
  end

  it 'validates cleanly' do
    mock_ui = Gem::MockGemUi.new
    Gem::DefaultUserInteraction.use_ui(mock_ui) { @gemspec.validate }

    expect(mock_ui.error).to_not match(/warn/i)
  end


  describe 'dependencies' do

    it 'works with Ruby 2 and 3' do
      ruby_version_limits = @gemspec.required_ruby_version.requirements.map(&:join)

      expect(ruby_version_limits).to match_array(['>=2.0', '<4.0'])
    end

  end

end
