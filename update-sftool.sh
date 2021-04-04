#! /bin/sh
set -euo pipefail
swift build --package-path tooling/sftool --configuration release
cp tooling/sftool/.build/release/sftool bin/sftool/sftool
