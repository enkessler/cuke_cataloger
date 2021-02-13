namespace 'cuke_cataloger' do

  desc 'Removes the contents of the test reporting directory'
  task :clear_report_directory do
    puts Rainbow('Clearing report directory...').cyan

    FileUtils.remove_dir(ENV['CUKE_CATALOGER_REPORT_FOLDER'], true)
    FileUtils.mkdir(ENV['CUKE_CATALOGER_REPORT_FOLDER'])
  end

  desc 'Removes existing test results and code coverage'
  task :clear_old_results => %i[clear_report_directory] # rubocop:disable Style/HashSyntax

end
