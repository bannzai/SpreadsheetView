Pod::Spec.new do |s|
  s.name             = 'SpreadsheetView'
  s.version          = '0.9.1'
  s.summary          = 'Full configurable spreadsheet view user interfaces for iOS applications.'
  s.description      = <<-DESC
                         Full configurable spreadsheet view user interfaces for iOS applications. With this framework,
                         you can easily create complex layouts like schedule, gantt chart or timetable as if you are using Excel.

                         Features
                         - Fixed column and row headers
                         - Merge cells
                         - Circular infinite scrolling automatically
                         - Customize grids and borders for each cell
                         - Customize inter cell spacing vertically and horizontally
                         - Fast scrolling, memory efficient
                         - `UICollectionView` like API
                         - Well unit tested
                       DESC
  s.homepage         = 'https://github.com/bannzai/SpreadsheetView'
  s.screenshots      = 'https://raw.githubusercontent.com/bannzai/SpreadsheetView/master/Resources/GanttChart.png', 'https://raw.githubusercontent.com/bannzai/SpreadsheetView/master/Resources/Timetable.png', 'https://raw.githubusercontent.com/bannzai/SpreadsheetView/master/Resources/DailySchedule_portrait.png'
  s.ios.deployment_target = '9.0'
  s.source_files     = 'Framework/Sources/*.swift'
  s.pod_target_xcconfig = { 'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES', 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
  s.frameworks = 'UIKit'
  s.source           = { :git => 'https://github.com/bannzai/SpreadsheetView.git', :tag => "v#{s.version}" }
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kishikawa Katsumi' => 'kishikawakatsumi@mac.com' }
  s.social_media_url = 'https://twitter.com/k_katsumi'

  s.swift_versions = '5.0'
end
