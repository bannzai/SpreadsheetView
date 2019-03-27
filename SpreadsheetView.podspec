

Pod::Spec.new do |spec|

  spec.name         = "SpreadsheetView"
  spec.version      = "0.8.5"
  spec.summary      = "Full configurable spreadsheet view user interfaces for iOS applications."

  spec.description  = <<-DESC
			Full configurable spreadsheet view user interfaces for iOS applications. With this framework,
	
                        you can easily create complex layouts like schedule, gantt chart or timetable as if you are using Excel.

                   DESC

  spec.homepage     = "https://github.com/vitaliypriydun/SpreadsheetView"

  spec.license      = { :type => 'MIT', :file => 'LICENSE' }

  spec.author             = { "vitalii_pryidun" => "vitaliy.priydun@gmail.com" }
  
  spec.platform     = :ios

  spec.source       = { :git => "https://github.com/vitaliypriydun/SpreadsheetView.git", :tag => "#{spec.version}" }


  spec.source_files     = 'Framework/Sources/*.swift'
  spec.pod_target_xcconfig = { 'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES', 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
  spec.frameworks = 'UIKit'
  

end
