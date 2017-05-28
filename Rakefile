require 'xcjobs'

namespace :test do
  desc 'test on simulator'
  task :iphonesimulator do |t|
    XCJobs::Test.new("simulator") do |t|
      configuration = ENV['CONFIGURATION'] || 'Release'
      destination = ENV['DESTINATION']
      testcase = ENV['TESTCASE']
      t.workspace = 'SpreadsheetView'
      t.scheme = 'SpreadsheetView'
      t.sdk = 'iphonesimulator'
      t.configuration = configuration
      t.add_only_testing("SpreadsheetViewTests/#{testcase}") unless testcase
      t.add_destination(destination) unless destination
      t.add_build_option('-enableCodeCoverage', 'YES')
      t.add_build_setting('ONLY_ACTIVE_ARCH', 'YES')
      t.add_build_setting('ENABLE_TESTABILITY', 'YES')
      t.build_dir = 'build'
    end
    Rake::Task['simulator'].execute
  end

  desc 'test on device'
  task :iphoneos do |t|
    XCJobs::Test.new("device") do |t|
      configuration = ENV['CONFIGURATION'] || 'Release'
      t.workspace = 'SpreadsheetView'
      t.scheme = 'SpreadsheetView'
      t.sdk = 'iphoneos'
      t.configuration = configuration
      t.add_build_setting('ENABLE_TESTABILITY', 'YES')
      t.build_dir = 'build'
    end
    Rake::Task['device'].execute
  end
end

namespace 'build-for-testing' do
  desc 'build for testing'
  XCJobs::Build.new("simulator") do |t|
    configuration = ENV['CONFIGURATION'] || 'Release'
    t.workspace = 'SpreadsheetView'
    t.scheme = 'SpreadsheetView'
    t.sdk = 'iphonesimulator'
    t.configuration = configuration
    t.add_build_option('-enableCodeCoverage', 'YES')
    t.add_build_setting('ENABLE_TESTABILITY', 'YES')
    t.build_dir = 'build'
    t.for_testing = true
  end
end

namespace 'test-without-building' do
  desc 'test on simulator without building'
  task :simulator do |t, args|
    XCJobs::Test.new("simulator") do |t|
      configuration = ENV['CONFIGURATION'] || 'Release'
      destination = ENV['DESTINATION'] || ''
      testcase = ENV['TESTCASE'] || ''
      t.workspace = 'SpreadsheetView'
      t.scheme = 'SpreadsheetView'
      t.sdk = 'iphonesimulator'
      t.configuration = configuration
      t.add_only_testing("SpreadsheetViewTests/#{testcase}") unless testcase
      t.add_destination(destination) unless destination
      t.add_build_option('-enableCodeCoverage', 'YES')
      t.build_dir = 'build'
      t.without_building = true
    end
    Rake::Task['simulator'].execute
  end
end

XCJobs::Coverage::Coveralls.new()
