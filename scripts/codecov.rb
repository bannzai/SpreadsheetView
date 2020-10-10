#!/usr/bin/env ruby

def build_coverage_reports()
  project_name = 'SpreadsheetView'
  profdata = Dir.glob(File.join('build', '/**/Coverage.profdata')).first
  Dir.glob(File.join('build', "/**/#{project_name}")) do |target|
    output = `xcrun llvm-cov report -instr-profile "#{profdata}" "#{target}" -arch=x86_64`
    if $?.success?
      puts output
      `xcrun llvm-cov show -instr-profile "#{profdata}" "#{target}" -arch=x86_64 -use-color=0 > ../coverage.txt`
      break
    end
  end
end

build_coverage_reports()
