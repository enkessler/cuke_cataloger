describe 'the gem' do

  here = File.dirname(__FILE__)

  let(:gemspec) { eval(File.read "#{here}/../../../cuke_cataloger.gemspec") }

  it 'has an executable' do
    expect(gemspec.executables).to include('cuke_cataloger')
  end

end
