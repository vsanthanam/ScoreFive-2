# Dasut

A command line helper used to develop ScoreFive, written in Swift.

## Introduction

Dasut is tool used to automate common operations like linting, running unit tests, and generating projects. It has a variety of subcommands that you can use to speed up development.
Dasut assumes that its being run from the root of the ScoreFive monorepo, but can be run from other places too. Most subcommands allow you to provide the optional `--repo-root` option and specify some alternate location if you're running the tool from some directory other than the repo root.

## Universal Options

All subcommands make use of the following options:

- `--trace`, displays verbose logging when provided
- `--repo-root <directory>`, uses the provided value as the location of the scorefive monorepo
- `--tool-configuration <>`, specifies the location the `.dasut-config` file, relative to the scorefive monrepo.
- `--help`, `-h`, Shows subcommand help info and subcommands, arguments & options

## Subcommands

### `bootstrap`

Prepare the repository for development initially. You typically only need to do this once.

Usage:
```
$ ./dasut bootstrap
```

### `develop`

Generates the `.xcworkspace` and `.xcodeproj` files, opens the xcode workspace in Xcode. Existing files will be overwritten. 

Usage:
```
$ ./dasut develop [--repo-root <repo-root>] [--tool-configuration <tool-configuration>] [--workspace-root <workspace-root>] [--bin <bin>] [--trace] [--dont-open-xcode]
```

*Options*
- `--workspace-root <root>` — The location of the workspace root directory within the scorefive monorepo. If none is provided, this value is inferred from `.dasut-config` file
- `--bin <bin>` — The location tuist binary. If no argument is provided, the default value of `bin/tuist/tuist` relative to the scorefive monorepo
- `--dont-open-xcode`, `-d` — When provided, the workspace & project files will be generated, but not opened.

### `update-deps`

Updates the runtime object dependency graph using `uber/needle`

Usage:
```
$ ./dasut update-deps [<output>] [<input>] [--bin <bin>] [--repo-root <repo-root>] [--tool-configuration <tool-configuration>] [--trace]
```

*Arguments*
- `<output>` — The location to write the dependency graph too. This argument expects a file, and the existing file will be overwritten
- `<input>` — The files to examine before genereating the dependency graph.

*Options*
- `--bin <bin>` — The location of the needle binary. If no argument is provided, the defailt value of `bin/needle/needle`, relative to the scorefive monorepo

### `mock`

Generates mock objects with mockolo

Usage:
```
$ ./dasut mock [<outputs> ...] [<inputs> ...] [--repo-root <repo-root>] [--tool-configuration <tool-configuration>] [--bin <bin>] [--trace]
```

*Arguments*
- `<outputs>` — Location(s) to write the mock files to.
- `<inputs>` — The directories to mock

*Options*
- `--bin <bin>` — The location the mockolo binary. If no argument os provided, the default value of `bin/mockolo/mockolo`

### `lint`
Lint `.swift` files

```
$ ./dasut lint [<input>] [--repo-root <repo-root>] [--tool-configuration <tool-configuration>] [--swift-version <swift-version>] [--exclude-dirs <exclude-dirs> ...] [--disabled-lint-rules <disabled-lint-rules> ...] [--enabled-lint-rules <enabled-lint-rules> ...] [--disabled-format-rules <disabled-format-rules> ...] [--enabled-format-rules <enabled-format-rules> ...] [--trace] [--autofix] [--arclint]
```

*Arguments*
- `<input>` — The file to lint. If no argument is provided, the entire monorepo is linted.

*Options*
- `--swift-version <swift-version>` — The version of swift to use. If none is provided, this value is inferred from the `.dasut-config` file
- `--exclude-dirs <exclude-dirs>` — Directories to exclude from linting. If none is provided, this value is inferred from the `.dasut-config` file
- `--disabled-lint-rules <disabled-lint-rules>` — `swiftlint` rules to disable. Additional values will be inferred from the `.dasut-config` file.
- `--enabled-lint-rules <enabled-lint-rules>` — `swiftlint` rules to enabled. Additional values will be inferred from the `.dasut-config` file.
- `--disabled-format-rules <disabled-format-rules>` — `swiftformat` rules to enabled. Additional values will be inferred from the `.dasut-config` file. 
- `--enabled-format-rules <enabled-format-rules>` — `swiftformat rules to enabled. Additional values will be inferred from the `.dasut-config` file.
- `--autofix` — Fix lint errors when possible.

### `test`
Run the unit tests

Usage:
```
$ ./dasut test [--repo-root <repo-root>] [--tool-configuration <tool-configuration>] [--device <device>] [--os <os>] [--workspace-root <workspace-root>] [--trace] [--pretty]
```

*Options*
- `--device <device>` — Simulator Device Name
- `--os <os>` — Simulator Version
- `--workspace-root <root>` — The location of the workspace root directory within the scorefive monorepo. If none is provided, this value is inferred from `.dasut-config` file
- `--pretty` — Display pretty results (requires `xcpretty`)

### `analytics`

The analytics command shouldn't be used by itself, but rather in conjunction with one of its two subcomands: `wipe` and `install`

#### `wipe`

Install an empty analytics configuration to disable analytics

Usage: 
```
$ ./dasut analytics wipe [--repo-root <repo-root>] [--workspace-root <workspace-root>] [--tool-configuration <tool-configuration>]
```

*Options*
- `--workspace-root <root>` — The location of the workspace root directory within the scorefive monorepo. If none is provided, this value is inferred from `.dasut-config` file

#### `install`

Install Countly Host & API Key

Usage:
```
$ ./dasut analytics install <host> <key> [--repo-root <repo-root>] [--tool-configuration <tool-configuration>] [--workspace-root <workspace-root>]
```

*Arguments*
- `<host>` — Countly server host
- `<key>` — Countly application key

*Options*
- `--workspace-root <root>` — The location of the workspace root directory within the scorefive monorepo. If none is provided, this value is inferred from `.dasut-config` file

### `clean`

Remove xcode project, workspaces, and other un-checkedin files from the repo.

Usage:
```
$ ./dasut clean [--repo-root <repo-root>] [--tool-configuration <tool-configuration>] [--trace] [--workspace-root <workspace-root>]
```

*Options*
- `--workspace-root <root>` — The location of the workspace root directory within the scorefive monorepo. If none is provided, this value is inferred from `.dasut-config` file

### `test-script`

*Options*
- `--device <device>` — Simulator Device Name
- `--os <os>` — Simulator Version
- `--workspace-root <root>` — The location of the workspace root directory within the scorefive monorepo. If none is provided, this value is inferred from `.dasut-config` file
- `--pretty` — Display pretty results (requires `xcpretty`)
- `--relaxed` — Allow lint failures in the generated script
- `--autoclean` — Perform a monorepo clean at the end of the generated script

## Configuration

Many of the required arguments can be loaded from the `./dasut-config` file. ... <TBA>
