#! /bin/sh
set -euo pipefail
swift build --package-path tooling/dasut --configuration release
cp tooling/dasut/.build/release/dasut bin/dasut/dasut