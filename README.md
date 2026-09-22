# reforge

A new Flutter project.

## Flutter version management

This project uses [FVM](https://fvm.app/) to pin Flutter `3.44.2`. The required
version is declared in `.fvmrc`; installing it does not change the globally
installed Flutter SDK.

Install the configured Flutter version and resolve project dependencies:

```bash
make -f MakeFile setup
```

The setup target runs `fvm install` and `fvm flutter pub get`. On subsequent
runs, use FVM for Flutter commands:

```bash
fvm flutter run
```

The existing `aab` and `ipa` MakeFile targets also use the FVM-managed Flutter
SDK.

### VS Code debugging

The workspace setting `dart.flutterSdkPath` must point to the stable FVM
symlink:

```json
"dart.flutterSdkPath": ".fvm/flutter_sdk"
```

After running the setup command, select the `reforge` configuration from
`.vscode/launch.json` and press F5. The Dart extension will use the Flutter
version selected by `.fvmrc`, so `launch.json` does not need a hard-coded SDK
version.

If the pinned version changes, run:

```bash
fvm use <version>
fvm flutter pub get
```

Because this repository currently uses the non-standard filename `MakeFile`,
invoke its targets with `make -f MakeFile <target>`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
