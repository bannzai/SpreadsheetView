#!/usr/bin/env ruby

class Binder 
  # You can confrim new device via `xcrun xctrace list devices`
  def test_target_os_and_device
    @test_target_os_and_device ||= {
      '14.0': [
        'iPad (8th generation)',
        'iPad Air (4th generation)',
        'iPad Pro (11-inch) (2nd generation)',
        'iPad Pro (12.9-inch) (4th generation)',
        'iPad Pro (9.7-inch)',
        'iPhone 11',
        'iPhone 11 Pro',
        'iPhone 11 Pro Max',
        'iPhone 8',
        'iPhone 8 Plus',
        'iPhone SE (2nd generation)'
      ],
      '13.0': [
        'iPhone 11 Pro Max',
      ],
    }
  end

  def versions
    test_target_os_and_device.keys
  end

  def devices(version)
    test_target_os_and_device[version]
  end

  def test_cases
    prefix = 'SpreadsheetViewTests'
    tests = [
      'SelectionTests',
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
    ]
    tests.map { |t| prefix + '/' + t }
  end

  def xcodebuilds
    xcodebuilds = []
    versions.each { |v|
      test_cases.each { |t|
        devices(v).each { |d|
          xcodebuilds.append(formatted(v, d, t))
        }
      }
    }
    xcodebuilds
  end

  def formatted(version, device, test_case)
    "xcodebuild test-without-building -workspace SpreadsheetView.xcworkspace -scheme SpreadsheetView -sdk iphonesimulator -configuration Release -derivedDataPath build -destination 'name=#{device},OS=#{version}' -enableCodeCoverage YES CONFIGURATION_TEMP_DIR=build/temp -only-testing:#{test_case}"
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

