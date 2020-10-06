#!/usr/bin/env ruby

class Binder 
  # You can confrim new device via `xcrun xctrace list devices`
  def latest_os
    '14.0'
  end

  def devices
    @devices ||= {
      'iphone': [
        'iPhone 11',
        'iPhone 11 Pro',
        'iPhone 11 Pro Max',
        'iPhone 8',
        'iPhone 8 Plus',
        'iPhone SE (2nd generation)'
      ],
      'ipad': [
        'iPad (8th generation)',
        'iPad Air (4th generation)',
        'iPad Pro (11-inch) (2nd generation)',
        'iPad Pro (12.9-inch) (4th generation)',
        'iPad Pro (9.7-inch)',
      ],
    }
  end

  def test_cases
    prefix = 'SpreadsheetViewTests'
    tests = [
      'CellRangeTests',
      'CellTests',
      'ConfigurationTests',
      'DataSourceTests',
      'HelperFunctions',
      'HelperObjects',
      'MergedCellTests',
      'PerformanceTests',
      'ScrollTests',
      'ViewTests',

      # These has a long time for test.
      'SelectionTests/testSelectItem',
      'SelectionTests/testAllowsSelection',
      'SelectionTests/testAllowsMultipleSelection',
      'SelectionTests/testTouches',
      'SelectionTests/testTouchesFrozenColumns',
      'SelectionTests/testTouchesFrozenRows',
      'SelectionTests/testTouchesFrozenColumnsAndRows',
    ]
    tests.map { |t| prefix + '/' + t }
  end

  def iphone_xcodebuilds
    xcodebuilds = []
    devices[:iphone].each { |d|
      xcodebuilds.append(formatted(latest_os, d, nil))
    }
    xcodebuilds
  end

  def ipad_xcodebuilds
    xcodebuilds = []
    test_cases.each { |t|
      devices[:ipad].each { |d|
        xcodebuilds.append(formatted(latest_os, d, t))
      }
    }
    xcodebuilds
  end

  def formatted(version, device, test_case)
    if test_case.nil?
      "xcodebuild test-without-building -workspace SpreadsheetView.xcworkspace -scheme SpreadsheetView -sdk iphonesimulator -configuration Release -derivedDataPath build -destination 'name=#{device},OS=#{version}' -enableCodeCoverage YES CONFIGURATION_TEMP_DIR=build/temp"
    else
      "xcodebuild test-without-building -workspace SpreadsheetView.xcworkspace -scheme SpreadsheetView -sdk iphonesimulator -configuration Release -derivedDataPath build -destination 'name=#{device},OS=#{version}' -enableCodeCoverage YES CONFIGURATION_TEMP_DIR=build/temp -only-testing:#{test_case}"
    end
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

