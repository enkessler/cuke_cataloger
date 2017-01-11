require "#{File.dirname(__FILE__)}/spec_helper"
require 'rubygems/mock_gem_ui'


describe 'the gem' do

  here = File.dirname(__FILE__)

  let(:gemspec) { eval(File.read "#{here}/../../../cuke_cataloger.gemspec") }

  it 'has an executable' do
    expect(gemspec.executables).to include('cuke_cataloger')
  end

  it 'validates cleanly' do
    mock_ui = Gem::MockGemUi.new
    Gem::DefaultUserInteraction.use_ui(mock_ui) { gemspec.validate }

    expect(mock_ui.error).to_not match(/warn/i)
  end

end
