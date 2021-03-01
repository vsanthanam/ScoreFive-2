#  ScoreFive
[![Build Status](https://jenkins.vsanthanam.com/buildStatus/icon?job=ScoreFive-iOS-Default)](https://jenkins.vsanthanam.com/job/ScoreFive-iOS-Default/)
[![License](https://img.shields.io/github/license/vsanthanam/scorefive-2)](https://opensource.org/licenses/MIT)

## Setup

ScoreFive is comprised of several proejcts and a single workspace.
Vendor code and other dependencies do not use a package manager, and are included in the repository directly.
Before opening the `.xcworkspace` and building the app, complete the following steps to setup the tooling

0. Install homebrew. More information is available at [https://brew.sh](https://brew.sh)

1. ScoreFive uses [Needle](https://www.github.com/uber/needle) for type-safe, scoped dependency injection. Install the needle code generation tools from uber/needle through homebrew:

```
$ brew install needle
```

2. ScoreFive uses [Mockolo](https://www.github.com/uber/mockolo) for efficient Swift mock generation. Install the mockolo code generation tools from uber/mockolo through homebrew. (This step is optional if you don't want to run the unit tests.)

```
$ brew install mockolo
```

3. Rather than interfacing with the aformentioned tools directly. ScoreFive provides a built-in command line utility called `sftool` to that knows the right arguments and paths to use. The source code for this tool is included in the repo. Build the tool and move it to the root directory:

```
$ cd path/to/repo
$ swift build --package-path Tooling/sftool --configuration release
$ cp Tooling/sftool/.build/release/sftool sftool
```

4. Prepare the repository for development

```
$ cd path/to/repo
$ ./sftool bootstrap
```

After these steps have been taken, you can open `ScoreFive.xcworkspace` and run the app.

## Development

This project is hosted at phab.vsanthanam.com and manage using phacility tools. The copy on github is just a mirror, and only contains the `main` branch. To contribute, visit [the hosted phabricator install](https://phab.vsanthanam.com) and request a user account.

### Running the Unit Tests

1. Generate the object mocks 

```
$ cd path/to/repo
$ ./sftool gen mocks
```

2. Run the tests with `xcodebuild` via with `sftool`

```
$ cd path/to/repo
$ ./sftool test
```
You can also open `ScoreFive.xcworkspae` and run the unit tests from within Xcode.

### Running SwiftFormat

You can run switformat on the repo with the correct rules and files using `sftool`:

1. Install `swiftformat` via homebrew

```
$ brew install swiftformat
```

2. Run `swiftformat` via `sftool`

```
$ cd path/to/repo
$ ./sftool format
```

### Running SwiftLint

You can run switlint on the repo with the correct rules and files using `sftool`:

1. Install `swiftlint` via homebrew

```
$ brew install swiftformat
```

2. Run `swiftlint` via `sftool`

```
$ cd path/to/repo
$ ./sftool lint
```

### Updating the DI Graph

```
$ cd path/to/repo
$ ./sftool gen deps
```

### Analytics Setup

ScoreFive uses Countly for user analytics. This feature is disabled by default, and you'll need your own hosted version of Countly to get it up and running.
If you have your own host, create an application key and install it with `sftool`

```
$ cd path/to/repo
$ ./sftool analytics install --key MY_COUNTLY_APP_KEY --host https://mycountlyhost.com
```

Similarly, you can remove any currently active analytics configuration with `sftool`

```
$ cd path/to/repo
$ ./sftool analytics wipe
```

### Configuring SFTool

To update the way SFTool behaves, you can edit the configuration file `/.sftool-config`. Here, you can edit things like the test target, swiftlint/swiftformat rules, needle & mockolo behavior, etc.
