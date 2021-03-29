#  ScoreFive
[![Build Status](https://img.shields.io/buildkite/d1c99f98602af9271e05a7020e2f18b941ed3a2f632d6eeb1b/refs/heads/main)](https://buildkite.com/varun-santhanam/scorefive-main-branch)
[![License](https://img.shields.io/github/license/vsanthanam/scorefive-2)](https://opensource.org/licenses/MIT)
[![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)
![Xcode](https://img.shields.io/badge/Xcode-12.4-blue)
![Swift](https://img.shields.io/badge/Swift-5.4-blueviolet)

## Setup

ScoreFive is comprised of several proejcts and a single workspace.
Vendor code and other dependencies do not use a package manager, and are included in the repository directly.
Xcode projects are generated using the provided tooling, and are not checked into the repo.

1. ScoreFive uses [Tuist](https://tuist.io/docs/usage/get-started/) for project generation, [uber/needle](https://github.com/uber/needle) for compile-time safe dependency injection and [uber/mockolo](https://github.com/uber/mockolo) for efficient Swift mock generation. The correct versions of these tools are bundled with the repo. Rather than interfacing with these tools directly, ScoreFive provides a built-in command line utility called `sftool` to that knows the right arguments, paths & settings use. `sftool` is integrated into arc workflows and the xcode workspace schemes. The source code for this tool is included in the repo.

Build the latest version of the tool and move it to the root directory with the provided script.

```
$ cd path/to/repo
$ ./update-sftool.sh
```

2. Prepare the repository for development

```
$ cd path/to/repo
$ ./sftool bootstrap
```
> *Warning*: If you get gatekeeper errors from macOS, navigate to `path/to/repo/bin/`, right click on the offending binary and click "open". This will tell the OS that you're okay to run the tool. You may need to do this for multiple binaries.

3. Finally, you can generate the Xcode projects with `./sftool`

```
$ cd path/to/repo
$ ./sftool develop
```

## Development

This project is hosted at phab.vsanthanam.com and manage using phacility tools. The copy on github is just a mirror, and only contains the `main` branch. To contribute, visit [the hosted phabricator install](https://phab.vsanthanam.com) and request a user account. You'll also need to [install arcanist](https://secure.phabricator.com/book/phabricator/article/arcanist_quick_start/)

### Running the Unit Tests

1. Generate the object mocks 

```
$ cd path/to/repo
$ ./sftool gen mocks
```

2. Run the tests with `tuist test` via with `sftool`

```
$ cd path/to/repo
$ ./sftool test
```
You can also open the workspace with `./sftool develop` and run the unit tests from within Xcode.

### Linting

ScoreFive uses `swiftformat` and `swiftlint` to lint swift source files. The correct versions are bundled in the repo.

To see a list of outstanding violations, use the lint command

```
$ cd path/to/repo
$ ./sftool lint
```

Some violations and formatting errors can be fixed automatically. To do this, add the `--fix` flag. 

The lint command always succeeds, even if there are outstanding violations. To have the command succeed only if there are no outstanding violations, add the `--test` flag. This flag should not be used with `--fix`. `--test` can be useful in CI jobs, if you want to prevent offending code from building
You can configure the rules and options in `.sftool-config`

By default ,`./sftool lint` runs on the entire repo, but you can provide a specific path to lint using the `--input` option.
You can also lint changed files only using `arc lint`

### Updating the DI Graph

1. Run `needle` via `sftool`

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

To see the current status, run `./sftool analytics status`

### Configuring SFTool

To update the way SFTool behaves, you can edit the configuration file `/.sftool-config`. Here, you can edit things like the test target, swiftlint/swiftformat rules, needle & mockolo behavior, etc.

### Continuous Integration

I use BuildKite for continuous builds. If you want to fork this repo and setup your own pipeline, `sftool` provides a handy utility to communicate a the right script to your runners. My script looks like this:

```
$ cd /path/to/repo
$ ./sftool gen ci > buildkite.sh
$ chmod +x buildkite.sh
$ /.buildkite.sh
```

You can customize the behavior of `./sftool gen ci` by editing `.sftool-config`.
