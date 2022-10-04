<p align="center">
    <img src="Art/logo.png" width="500" max-width="90%" alt="Cloak Swift" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" />
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

This is **Cloak Swift** - a tool and Tuist plugin to encrypt secrets and then pass them in an obfuscated form into applications.

&nbsp;

<p align="center">
    <a href="#features">Features</a> • <a href="#install">Install</a> • <a href="#usage">Usage</a> • <a href="#contributing-or-help">Contributing</a>
</p>

## Features

#### ☑️ Keep your secrets out of Git

Set up secrets locally outside of the Git repository to avoid them being embedded into the code.

#### ☑️ Encrypt secrets

Create encryption key and encrypt secrets ready for use.

#### ☑️ Access secrets from your app

Generate a Swift file to access the secrets from your app's code.

#### ☑️ Obfuscation

The generated Swift uses obfuscation of the values rather than as raw strings.

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
        .git(url: "https://github.com/lordcodes/cloak-swift.git", tag: "vTAG")
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
.package(url: "https://github.com/lordcodes/cloak-swift", exact: "VERSION")
```

&nbsp;

## Usage

### Set up configuration

Create a configuration file within your project: `.cloak/config`, this file should be kept in Git and shared between contributors. Enter key-value pairs into the file [EnvironmentKey](Sources/CloakKit/Configuration/EnvironmentKey.swift).

* CLOAK_SECRETS_CLASS_NAME -> Name to give the generated Swift enum that contains the secrets in-app.
* CLOAK_SECRETS_OUTPUT_FILEPATH -> File path to put the generated Swift file.
* CLOAK_SECRETS_ACCESS_LEVEL -> Swift access level to give to the enum and each secret static property. E.g. public.

Each of these settings can be provided as an environment variable instead of listed in the configuration file. The config file will take precedance.

For example:

```
CLOAK_SECRETS_CLASS_NAME=AppSecrets
CLOAK_SECRETS_OUTPUT_FILEPATH=Sources/Generated/AppSecrets.swift
CLOAK_SECRETS_ACCESS_LEVEL=public
```

### Configure required secret keys

You can list the required secret keys for your project in a `.cloak/secret-keys` file, which can be kept in Git. This ensures each contributor has provided all required secrets locally. Secret keys should be listed one on each line.

For example:

```
ANALYTICS_WRITE_KEY
API_CLIENT_ID
API_CLIENT_SECRET
```

### Configure secrets

Each contributor on a project will need to create a file at `.cloak/secrets` that uses the same format as the `config` file but that lists secret key names and values. This file should be added to your project's `.gitignore` to keep them out of Git.

You should also add your encryption key to this file using the key name `CLOAK_ENCRYPTION_KEY`. This will allow the encrypt/decrypt commands to function and will also allow it to be included into the generated Swift file so that your app can decrypt the secrets at runtime in order to use them.

If the secret keys are specified in the required keys file `secret-keys`, then they will be read as environment variables as well, where the environment variables take precendence. This is useful in a CI environment where you can specify them as environment variables and avoid having to write them to a file as you would locally.

IMPORTANT NOTE: The secrets aren't read as environment variables correctly when using Cloak as a Tuist plugin, due to the environment Tuist plugins are executed in. Therefore, it is best to write the secrets to a file in a setup step of your CI workflow.

The best practice is that the values should be encrypted first.

### 🖥 Via the Tuist Plugin

Run Cloak's tasks via Tuist. The tool will check paths relative to the working directory for the `.cloak` directory configured above.

```terminal
USAGE: tuist cloak <subcommand> [-q|--quiet]

SUBCOMMANDS:
  createkey  Create encryption key.
  decrypt    Decrypt a value encrypted using cloak.
  encrypt    Encrypt a value.
  generate   Read in secrets, obfuscate them and then generate a Swift file to access them within an app.
  version    Print version.

OPTIONS:
  -q, --quiet             Silence any output except errors 
```

You can obtain help using `tuist cloak --help` and also obtain help for each subcommand using `tuist cloak <subcommand> --help`.

#### Create encryption key

Generates an encryption key, that can then be used within your project to encrypt secrets. This key is then passed into your app so that you can decrypt them at runtime.

`tuist cloak createkey`

#### Encrypt a value

Provide a value and the encrypted version will be returned. Your encryption key should be provided as described above.

`tuist cloak encrypt <value>`

#### Decrypt an encrypted value

Provide an encrypted value and the decrypted version will be returned. Your encryption key should be provided as described above.

`tuist cloak decrypt <encrypted>`

#### Generate a secrets file in-app

Generate a Swift file that can be used to access your secrets within your app at runtime. Certain aspects of the generated file can be customised using the `config` file as described above. The secrets will be obfuscated and included as `[UInt8]`, but with Swift properties to return them as `String` in their usable form.

`tuist cloak generate`

### 🖥 Via the Standalone CLI

Run Cloak's tasks via a standalone executable. The tool will check paths relative to the working directory for the `.cloak` directory configured above.

```terminal
USAGE: cloakswift <subcommand> [-q|--quiet]
```

Same usage as the Tuist plugin, except `tuist cloak` is replaced with `cloakswift`.

### 📦 As a Swift Package

To use Cloak Swift within your own Swift code, import and use the public API of `CloakKit`.

```swift
import CloakKit

// Configure printing
Cloak.shared.printer = ConsolePrinter(quiet: false)

EncryptionService().createKey()
```

## Contributing or Help

If you notice any bugs or have a new feature to suggest, please check out the [contributing guide](https://github.com/lordcodes/cloak-swift/blob/master/CONTRIBUTING.md). If you want to make changes, please make sure to discuss anything big before putting in the effort of creating the PR.

To reach out, please contact [@lordcodes on Twitter](https://twitter.com/lordcodes).
