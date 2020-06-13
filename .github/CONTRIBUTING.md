# Contributing to Fluent

👋 Welcome to the Vapor team! 

## Packages

The `fluent` package integrates [`fluent-kit`](https://github.com/vapor/fluent-kit) with [`vapor`](https://github.com/vapor/vapor). Most of the ORM code lives in FluentKit. 

Driver packages can be found by searching GitHub for [`#fluent-driver`](https://github.com/topics/fluent-driver). Each driver package will also usually contain relatively little code with most of the functionality coming from lower level packages. 

## Xcode

To open Fluent in Xcode:

- Clone the repo to your computer
- Drag and drop the folder onto Xcode

To test within Xcode, press `CMD+U`.

## SPM

To develop using SPM, open the code in your favorite code editor. Use the following commands from within the project's root folder to build and test.

```sh
swift build
swift test
```

## SemVer

Vapor follows [SemVer](https://semver.org). This means that any changes to the source code that can cause
existing code to stop compiling _must_ wait until the next major version to be included. 

Code that is only additive and will not break any existing code can be included in the next minor release.

----------

Join us on Discord if you have any questions: [vapor.team](http://vapor.team).

&mdash; Thanks! 🙌
