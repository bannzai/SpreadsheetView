require 'xcjobs'

namespace :test do
  desc 'test on simulator'
  XCJobs::Test.new("simulator") do |t|
    configuration = ENV['CONFIGURATION'] || 'Release'
    destinations = eval(ENV['DESTINATIONS'] || '[]')
    testcase = ENV['TESTCASE']

    t.workspace = 'SpreadsheetView'
    t.scheme = 'SpreadsheetView'
    t.sdk = 'iphonesimulator'
    t.configuration = configuration

    destinations.each { |destination| t.add_destination(destination) }
    t.add_only_testing("SpreadsheetViewTests/#{testcase}") if testcase
    t.add_build_option('-enableCodeCoverage', 'YES')
    t.add_build_setting('ENABLE_TESTABILITY', 'YES')
    t.add_build_setting('ONLY_ACTIVE_ARCH', 'NO')
    t.build_dir = 'build'
    t.after_action do
      build_coverage_reports()
    end
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
  XCJobs::BuildForTesting.new("simulator") do |t|
    configuration = ENV['CONFIGURATION'] || 'Release'

    t.workspace = 'SpreadsheetView'
    t.scheme = 'SpreadsheetView'
    t.sdk = 'iphonesimulator'
    t.configuration = configuration
    t.add_build_option('-enableCodeCoverage', 'YES')
    t.add_build_setting('ENABLE_TESTABILITY', 'YES')
    t.add_build_setting('ONLY_ACTIVE_ARCH', 'NO')
    t.build_dir = 'build'
  end
end

namespace 'test-without-building' do
  desc 'test on simulator without building'
  XCJobs::TestWithoutBuilding.new("simulator") do |t|
    configuration = ENV['CONFIGURATION'] || 'Release'
    destinations = eval(ENV['DESTINATIONS'] || '[]')
    testcase = ENV['TESTCASE']

    t.workspace = 'SpreadsheetView'
    t.scheme = 'SpreadsheetView'
    t.sdk = 'iphonesimulator'
    t.configuration = configuration
    destinations.each { |destination| t.add_destination(destination) }
    t.add_only_testing("SpreadsheetViewTests/#{testcase}") if testcase
    t.add_build_option('-enableCodeCoverage', 'YES')
    t.build_dir = 'build'
    t.after_action do
      build_coverage_reports()
    end
  end
end

def build_coverage_reports()
  project_name = 'SpreadsheetView'
  profdata = Dir.glob(File.join('build', '/**/Coverage.profdata')).first
  Dir.glob(File.join('build', "/**/#{project_name}")) do |target|
    output = `xcrun llvm-cov report -instr-profile "#{profdata}" "#{target}" -arch=x86_64`
    if $?.success?
      puts output
      `xcrun llvm-cov show -instr-profile "#{profdata}" "#{target}" -arch=x86_64 -use-color=0 > coverage.txt`
      break
    end
  end
end
