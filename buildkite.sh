#! /bin/sh
./sftool analytics wipe
./sftool gen deps
./sftool gen mocks
./sftool develop -n
set -euo pipefail
xcodebuild -workspace ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=iPhone 8 Plus,OS=14.4' test | tee -a build.log | xcpretty -c
