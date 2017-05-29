require 'xcjobs'

namespace :test do
  desc 'test on simulator'
  XCJobs::Test.new("simulator") do |t|
    configuration = ENV['CONFIGURATION'] || 'Release'
    destination = ENV['DESTINATION']
    testcase = ENV['TESTCASE']

    t.workspace = 'SpreadsheetView'
    t.scheme = 'SpreadsheetView'
    t.sdk = 'iphonesimulator'
    t.configuration = configuration
    t.add_destination(destination) if destination
    t.add_only_testing("SpreadsheetViewTests/#{testcase}") if testcase
    t.add_build_option('-enableCodeCoverage', 'YES')
    t.add_build_setting('ENABLE_TESTABILITY', 'YES')
    t.add_build_setting('ONLY_ACTIVE_ARCH', 'YES')
    t.build_dir = 'build'
  end

  desc 'test on device'
  XCJobs::Test.new("device") do |t|
    configuration = ENV['CONFIGURATION'] || 'Release'

    t.workspace = 'SpreadsheetView'
    t.scheme = 'SpreadsheetView'
    t.sdk = 'iphoneos'
    t.configuration = configuration
    t.add_build_setting('ENABLE_TESTABILITY', 'YES')
    t.build_dir = 'build'
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
  XCJobs::Test.new("simulator") do |t|
    configuration = ENV['CONFIGURATION'] || 'Release'
    destination = ENV['DESTINATION']
    testcase = ENV['TESTCASE']

    t.workspace = 'SpreadsheetView'
    t.scheme = 'SpreadsheetView'
    t.sdk = 'iphonesimulator'
    t.configuration = configuration
    t.add_destination(destination) if destination
    t.add_only_testing("SpreadsheetViewTests/#{testcase}") if testcase
    t.add_build_option('-enableCodeCoverage', 'YES')
    t.build_dir = 'build'
    t.without_building = true
  end
end

XCJobs::Coverage::Coveralls.new()
