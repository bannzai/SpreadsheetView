#!/bin/sh

set -eu
set -o pipefail

cd "`dirname $0`/../"

xcodebuild build-for-testing -workspace SpreadsheetView.xcworkspace -scheme SpreadsheetView -sdk iphonesimulator -configuration Release -derivedDataPath build -hideShellScriptEnvironment -enableCodeCoverage YES ENABLE_TESTABILITY=YES ONLY_ACTIVE_ARCH=NO EXCLUDED_ARCHS[sdk=iphonesimulator*]=arm64 CONFIGURATION_TEMP_DIR=build/temp
