#! /bin/sh

swift build --package-path Tooling/sftool --configuration release
cp Tooling/sftool/.build/release/sftool bin/sftool/sftool
