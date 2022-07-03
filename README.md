<p align="center">
    <img src="Art/logo.png" width="500" max-width="90%" alt="Cloak Swift" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.6-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
     <a href="https://github.com/lordcodes/cloak-swift/releases/latest">
         <img src="https://img.shields.io/github/release/lordcodes/cloak-swift.svg?style=flat" alt="Latest release" />
     </a>
    <a href="https://twitter.com/lordcodes">
        <img src="https://img.shields.io/badge/twitter-@lordcodes-blue.svg?style=flat" alt="Twitter: @lordcodes" />
    </a>
</p>

---

This is **Cloak Swift** - a tool and Tuist plugin to encrypt secrets and then pass them obfuscated into applications.

&nbsp;

<p align="center">
    <a href="#features">Features</a> • <a href="#install">Install</a> • <a href="#usage">Usage</a> • <a href="#contributing-or-help">Contributing</a>
</p>

## Features

&nbsp;

## Install

The primary intention was to use Cloak Swift as a [Tuist](https://github.com/tuist/tuist) plugin, however, it can also be used as a standard CLI tool as well.

### ▶︎ 🖥 As a Tuist Plugin

To set up as a Tuist plugin in your project simply follow the [Tuist plugin install instructions](https://docs.tuist.io/plugins/using-plugins/) using the [latest version](https://github.com/lordcodes/cloak-swift/releases/latest).

Add the plugin to `Config.swift`.

```swift
import ProjectDescription

let config = Config(
    plugins: [
        .git(url: "https://github.com/lordcodes/cloak-swift.git", tag: "{ENTER_LATEST_VERSION}")
    ]
)
```

### ▶︎ 🖥 Standalone via Swift Package Manager

Cloak Swift can be easily installed globally using Swift Package Manager.

```terminal
 git clone https://github.com/lordcodes/cloak-swift
 cd cloak-swift
 make install
```

This will install cloakswift into `/usr/local/bin`. If you get a permission error it may be that you don't have permission to write there in which case you just need to adjust permissions using `sudo chown -R $(whoami) /usr/local/bin`.

You can uninstall it again using `make uninstall` which simply deletes it from `/usr/local/bin`.

### ▶︎ 🍺 Homebrew

Support for Homebrew may be planned in the future.

### ▶︎ 📦 As a Swift package

To install Cloak Swift for use in your own Swift code, add it is a Swift Package Manager dependency within your `Package.swift` file. For help in doing this, please check out the Swift Package Manager documentation.

```swift
.package(url: "https://github.com/lordcodes/cloak-swift", exact: "0.0.1")
```

&nbsp;

## Usage

### 🖥 Via the Tuist Plugin

Ensure you have fetched with `tuist fetch` and you will then be able to run the plugin's tasks.

```terminal
USAGE: tuist cloak <createkey|version> [-q|--quiet]

ARGUMENTS:
  <createkey>             Create encryption key.
  <version>               Prints out the current version of the tool.

OPTIONS:
  -q, --quiet             Silence any output except errors 
```

### 🖥 Via the Standalone CLI

```terminal
USAGE: cloakswift <createkey|version> [-q|--quiet]

ARGUMENTS:
  <createkey>             Create encryption key.
  <version>               Prints out the current version of the tool.

OPTIONS:
  -q, --quiet             Silence any output except errors 
```

### 📦 As a Swift Package

To use Cloak Swift within your own Swift code, import and use the public API of `CloakKit`.

```swift
import CloakKit

// Configure printing
Cloak.configuration.printer = ConsolePrinter(quiet: false)

// Create key
EncryptionService().createKey()
```

## Contributing or Help

If you notice any bugs or have a new feature to suggest, please check out the [contributing guide](https://github.com/lordcodes/cloak-swift/blob/master/CONTRIBUTING.md). If you want to make changes, please make sure to discuss anything big before putting in the effort of creating the PR.

To reach out, please contact [@lordcodes on Twitter](https://twitter.com/lordcodes).
