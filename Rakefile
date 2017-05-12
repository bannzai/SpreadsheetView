require 'xcjobs'

namespace :test do
  desc 'test on simulator'
  task 'iphonesimulator', 'configuration', 'name', 'os'
  task 'iphonesimulator' do |t, args|
    XCJobs::Test.new("simulator") do |t|
      t.workspace = 'SpreadsheetView'
      t.scheme = 'SpreadsheetView'
      t.sdk = 'iphonesimulator'
      configuration = args['configuration'] || 'Debug'
      t.configuration = configuration
      if configuration == 'Release'
        t.add_build_setting('ENABLE_TESTABILITY', 'YES')
      end
      t.add_destination("name=#{args['name']},OS=#{args['os']}")
      t.coverage = true
      t.build_dir = 'build'
      t.formatter = 'xcpretty'
    end
    Rake::Task['simulator'].execute
  end

  desc 'test on device'
  task 'iphoneos', 'configuration'
  task 'iphoneos' do |t, args|
    XCJobs::Test.new("device") do |t|
      t.workspace = 'SpreadsheetView'
      t.scheme = 'SpreadsheetView'
      t.sdk = 'iphoneos'
      configuration = args['configuration'] || 'Debug'
      t.configuration = configuration
      if configuration == 'Release'
        t.add_build_setting('ENABLE_TESTABILITY', 'YES')
      end
      t.coverage = true
      t.build_dir = 'build'
      t.formatter = 'xcpretty'
    end
    Rake::Task['device'].execute
  end
end

XCJobs::Coverage::Coveralls.new()
