#!/usr/bin/env ruby

class Binder 
  # You can confrim new device via `xcrun xctrace list devices`
  def latest_os
    '14.0'
  end

  def devices
    @devices ||= [
        'iPhone 11',
        'iPhone 11 Pro',
        'iPhone 11 Pro Max',
        'iPhone 8',
        'iPhone 8 Plus',
        'iPhone SE (2nd generation)',
        'iPad (8th generation)',
        'iPad Air (4th generation)',
        'iPad Pro (11-inch) (2nd generation)',
        'iPad Pro (12.9-inch) (4th generation)',
        'iPad Pro (9.7-inch)',
      ]
  end
  def minimum_device
    'iPhone SE (2nd generation)'
  end

  def long_time_test_name
    'SpreadsheetViewTests/ScrollTests'
  end
  def long_time_test_methods
    [
      "#{long_time_test_name}/testTableViewScrolling",
      "#{long_time_test_name}/testColumnHeaderViewScrolling",
      "#{long_time_test_name}/testRowHeaderViewScrolling",
      "#{long_time_test_name}/testColumnAndRowHeaderViewScrolling",
      "#{long_time_test_name}/testCircularScrolling",
    ]
  end

  def xcodebuilds_ignore_long_time_testing
    xcodebuilds = []
    devices.each { |device|
      script = "xcodebuild test-without-building -workspace SpreadsheetView.xcworkspace -scheme SpreadsheetView -sdk iphonesimulator -configuration Release -derivedDataPath build -destination 'name=#{device},OS=#{latest_os}' -enableCodeCoverage YES CONFIGURATION_TEMP_DIR=build/temp -skip-testing:#{long_time_test_name}"
      xcodebuilds.append(script)
    }
    xcodebuilds
  end

  def xcodebuilds_for_long_time_testing
    xcodebuilds = []
    long_time_test_methods.each { |test_case|
      devices.each { |device|
        script = "xcodebuild test-without-building -workspace SpreadsheetView.xcworkspace -scheme SpreadsheetView -sdk iphonesimulator -configuration Release -derivedDataPath build -destination 'name=#{device},OS=#{latest_os}' -enableCodeCoverage YES CONFIGURATION_TEMP_DIR=build/temp -only-testing:#{test_case}"
        xcodebuilds.append(script)
      }
    }
    xcodebuilds
  end

  def get_binding
    binding
  end
end

require 'erb'

binder = Binder.new
template = ERB.new(File.read('travis.yml.erb'), nil, '-')
content = template.result(binder.get_binding)
File.write('.travis.yml', content)

