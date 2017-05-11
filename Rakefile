require 'xcjobs'
require 'json'

def destinations(platform: 'iphonesimulator')
  if platform == 'iphonesimulator'
    [ 
      'name=iPhone 4s,OS=9.3',
      # 'name=iPhone 5,OS=9.3',
      # 'name=iPhone 5s,OS=10.2',
      # 'name=iPhone 6s,OS=10.2',
      'name=iPhone 6s Plus,OS=10.2',
      'name=iPhone SE,OS=10.2',
      # 'name=iPad 2,OS=9.3',
      # 'name=iPad Air 2,OS=10.2',
      # 'name=iPad Pro (9.7 inch),OS=10.2',
      'name=iPad Pro (12.9 inch),OS=10.2',
    ]
  else
    []
  end
end

def supportedPlatforms
  ['iphoneos', 'iphonesimulator']
end
    
namespace :test do
  supportedPlatforms.each do |platform|
    XCJobs::Test.new("#{platform}") do |t|
      t.workspace = 'SpreadsheetView'
      t.scheme = 'SpreadsheetView'
      t.sdk = platform
      destinations(platform: platform).each do |destination|
        t.add_destination(destination)
      end
      t.configuration = 'Debug'
      t.coverage = true
      t.build_dir = 'build'
    end
  end
end

XCJobs::Coverage::Coveralls.new()
