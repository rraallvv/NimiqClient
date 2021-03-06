Nimiq Swift Client
==================

[![build](https://github.com/rraallvv/NimiqClientSwift/workflows/build/badge.svg)](https://github.com/rraallvv/NimiqClientSwift/actions)
![Swift PM](https://img.shields.io/badge/Dependency%20Manager-Swift%20PM-orange)
[![Cocoapods version](https://img.shields.io/cocoapods/v/NimiqClient)](https://cocoapods.org/pods/NimiqClient)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![Platforms](https://img.shields.io/cocoapods/p/NimiqClient)](http://cocoapods.org/pods/NimiqClient)
[![Maintainability](https://api.codeclimate.com/v1/badges/743444e5b64f84099c04/maintainability)](https://codeclimate.com/github/rraallvv/NimiqClientSwift/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/rraallvv/NimiqClientSwift/badge.svg?branch=master)](https://coveralls.io/github/rraallvv/NimiqClientSwift?branch=master)

> Swift implementation of the Nimiq RPC client specs.

## Usage

Send requests to a Nimiq node with `NimiqClient` object.

```swift
let config = Config(
    scheme: "http",
    host: "127.0.0.1",
    port: 8648,
    user: "luna",
    password: "moon"
)

let client = NimiqClient(config: config)
```

Once the client have been set up, we can call the methodes with the appropiate arguments to make requests to the Nimiq node.

When no `config` object is passed in the initialization it will use defaults for the Nimiq node.

```swift
let client = NimiqClient()

// make rpc call to get the block number
let blockNumber = client.blockNumber()

print(blockNumber) // displays the block number, for example 748883
```

## API

The complete [API documentation](docs) is available in the `/docs` folder.

Check out the [Nimiq RPC specs](https://github.com/nimiq/core-js/wiki/JSON-RPC-API) for behind the scene RPC calls.

## Installation

### Swift Package Manager

The recommended way to install Nimiq Swift Client is via Swift Package Manager (SPM). SPM is a dependency management tool built-in in Xcode that
allows you to add Swift packages as dependencies directly from the IDE.

From your project or workspace on Xcode Go to **File > Swift Packages > Add Package Dependency**. If it's a workspace select the project to include de package dependency in. Then enter this package's repository URL (like this https://github.com/rraallvv/NimiqClientSwift). Select a version number from thos available for the pacakge and click next. Then select the product target to include the dependency in.

### CocoaPods

Alternatively, you can install Nimiq Swift Client using CocoaPods. CocoaPods is a command line interface dependency management tool for Xcode projects.

Install CocoaPods if you haven't done so:

```sh
$ sudo gem install cocoapods
```

To enable CocoaPods in your project, close Xcode and in your project directory run:

```sh
$ pod init
```

Then you can add Nimiq Swift Client as a dependency modifying the created `Podfile`. To open the file for editing run `open -a Xcode Podfile` from the command line and the edit the file like so:

```sh
target "MyApp" do
    pod 'NimiqClient'
end
```

Finally install all the dependencies using CocoaPods from the command line: 

```sh
$ pod install
```

You can find out more on how to install CocoaPods and how to configure your Xcode project for installing dependencies at [CocoaPods.org](https://cocoapods.org).

### Carthage

Another option is to use Carthage. Carthage is another comandline interface dependency management tool for Xcode projects.

Install Carthage via the .pkg installer [available on their repository](https://github.com/Carthage/Carthage/releases) or via Homebrew:

```sh
$ brew install carthage
```

Create the file `Cartfile` in the project root directory:

```sh
$ touch Cartfile
```
Add the NimiqClient dependency to `Cartfile`:

```sh
github "rraallvv/NimiqClientSwift"
```

Install the dependencies using `carthage` command line interface:

```sh
$ carthage update --platform <your target platform>
```

After a few minutes when the operation is competed, open your project on Xcode and add `NimiqClient.framework` from the directory `Carthage/Build/<your target platform>/` onto your project's **Frameworks and Libraries** list of dependencies.

## Contributions

This implementation was originally contributed by [rraallvv](https://github.com/rraallvv/).

Please send your contributions as pull requests.

Refer to the [issue tracker](https://github.com/rraallvv/NimiqClientSwift/issues) for ideas.

### Develop

After cloning the repository, open the workspace file in NimiqClient/NimiqClient.xcworkspace instead of the project file.

All done, happy coding!

### Testing

Tests are stored in the `/Tests` folder and can be run from Xcode.

### Documentation

The documentation is generated automatically running Jazzy from the repository root directory. To install Jazzy run:

```
$ gem install jazzy
```

To generate the documentation run:

```
$ jazzy
```

## License

[MIT](LICENSE)
