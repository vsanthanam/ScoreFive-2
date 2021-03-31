#! /bin/sh

swift build --package-path tooling/sftool --configuration release
cp tooling/sftool/.build/release/sftool bin/sftool/sftool
