# flutter_updater_package

An easy way to implement OTA updates.

## Getting Started

First you need to mark the dependency ([package]: [version]) in the pubspec.yaml.
Then all you need to do is import the package into a dart file and call Updater.checkUpdates ([String currentVersion], [String latestVersionPath], [String updateUrlPath]);

All arguments:

  Required arguments:

  String [currentVersion] = "x.x.x" -> The current version as a string.
  String [latestVersionPath] = "http://... || https://..." -> http address where the latest version is saved as a string.
  String [updateUrlPath] = "http://... || https://..." -> http address after URL is saved from which the update will be downloaded.

  Optional arguments:

  bool [sampleUpdate] = "bool" -> If true, it will only show the change of update status. The arguments: [latestVersionPath], [updateUrlPath] will not be considered.
  Function [setState] = "(){}" -> It is possible to pass a function that is called whenever the update status changes and always during the download. This argument is meant to call the setState () {} of a widget to show information about the status of the update.
  int [delay] = "seconds" = If [sampleUpdate] = true, the status of the update will change every x seconds.

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
