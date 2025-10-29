fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build_xdrip4ios

```sh
[bundle exec] fastlane ios build_xdrip4ios
```

Build Xdrip4iOS

### ios release

```sh
[bundle exec] fastlane ios release
```

Push to TestFlight

### ios identifiers

```sh
[bundle exec] fastlane ios identifiers
```

Provision Identifiers and Certificates

### ios certs

```sh
[bundle exec] fastlane ios certs
```

Provision Certificates

### ios validate_secrets

```sh
[bundle exec] fastlane ios validate_secrets
```

Validate Secrets

### ios nuke_certs

```sh
[bundle exec] fastlane ios nuke_certs
```

Nuke Certs

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
