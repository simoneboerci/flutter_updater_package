library flutter_updater_package;

import 'dart:io';

import 'package:dio/dio.dart'; //Manage http requests.
import 'package:open_file/open_file.dart'; //It takes care of opening the file.
import 'package:path_provider/path_provider.dart'; //Used to get the location where the update will be downloaded.
import 'package:permission_handler/permission_handler.dart'; //Manage storage access permission.

enum UpdateStatus {
  checkingVersions,
  updateFound,
  checkingPermissions,
  downloading,
  writing,
  opening,
  done,
  upToDate,
  doneWithError,
}

class Updater {
  static UpdateStatus status;

  //Number of byte recived
  static int recived;
  //Number of total bytes
  static int total;

  ///
  ///Required arguments
  ///
  ///String [currentVersion] = "x.x.x" -> The current version as a string.
  ///String [latestVersionPath] = "http://... || https://..." -> http address where the latest version is saved as a string.
  ///String [updateUrlPath] = "http://... || https://..." -> http address after URL is saved from which the update will be downloaded.
  ///
  ///Optional arguments
  ///
  ///bool [sampleUpdate] = "bool" -> If true, it will only show the change of update status. The arguments: [latestVersionPath], [updateUrlPath] will not be considered.
  ///Function [setState] = "(){}" -> It is possible to pass a function that is called whenever the update status changes and always during the download. This argument is meant to call the setState () {} of a widget to show information about the status of the update.
  ///int [delay] = "seconds" = If [sampleUpdate] = true, the status of the update will change every x seconds.
  ///

  static Future<void> checkUpdates(
      String currentVersion, String latestVersionPath, String updateUrlPath,
      {bool sampleUpdate = false, Function setState, int delay = 1}) async {
    status = UpdateStatus.checkingVersions;
    setState();

    //Checking if the current version is the latest version.
    var _latestVersion;

    final _dio = Dio();

    if (!sampleUpdate) {
      //Try to get the value of the latest version via http.
      var _response = await _dio.get(latestVersionPath);
      _dio.close();

      _latestVersion = int.tryParse(_response.data.replaceAll('.', ''));
    } else {
      _latestVersion = int.tryParse(latestVersionPath.replaceAll('.', ''));
      await Future.delayed(Duration(seconds: delay));
    }

    if (_latestVersion == null) {
      status = UpdateStatus.doneWithError;
      setState();
      return;
    }

    final _currentVersion = int.tryParse(currentVersion.replaceAll('.', ''));

    //Compare the current version with the latest version available.
    if (_latestVersion > _currentVersion) {
      status = UpdateStatus.updateFound;
      setState();
    } else {
      status = UpdateStatus.upToDate;
      setState();
      return;
    }

    if (sampleUpdate) await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.checkingPermissions;
    setState();

    //Checking storage access permissions.
    final _storagePermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    //Request access permissions.
    if (_storagePermission != PermissionStatus.granted)
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    if (_storagePermission != PermissionStatus.granted) {
      status = UpdateStatus.doneWithError;
      setState();
      return;
    }

    Directory _fileDirectory;

    //Checking the directory where the update will be downloaded.
    if (!sampleUpdate) {
      final _directory = await getExternalStorageDirectory();
      _fileDirectory = Directory("${_directory.path}/./update");

      //Check if the directory exists.
      if (!await _fileDirectory.exists()) {
        try {
          _fileDirectory.create();
        } catch (exception) {
          status = UpdateStatus.doneWithError;
          setState();
          return;
        }
      }
    } else
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.downloading;
    setState();

    //Downloading the update.
    var _updateUrl;

    if (!sampleUpdate) {
      //Get the URL from which to download the update file.
      try {
        _updateUrl = await _dio.get(updateUrlPath);
      } catch (exception) {
        status = UpdateStatus.doneWithError;
        setState();
        return;
      } finally {
        _dio.close();
      }
    } else
      await Future.delayed(Duration(seconds: delay));

    const String updateFileName = "update";

    if (!sampleUpdate) {
      //Download the file.
      try {
        await _dio.download(
            _updateUrl.data, "${_fileDirectory.path}/$updateFileName.apk",
            onReceiveProgress: (recived, total) {
          Updater.recived = recived;
          Updater.total = total;
          setState();
        });
      } catch (exception) {
        status = UpdateStatus.doneWithError;
        setState();
        return;
      } finally {
        _dio.close();
      }
    } else
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.writing;
    setState();

    //Writing the file in memory.
    File _file;

    if (!sampleUpdate) {
      _file = File("${_fileDirectory.path}/$updateFileName.apk");

      //Check if the file exists.
      if (!await _file.exists()) {
        try {
          _file.create();
        } catch (exception) {
          status = UpdateStatus.doneWithError;
          setState();
          return;
        }
      }
    } else
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.opening;
    setState();

    //Starting the Android packages installation intent.
    if (!sampleUpdate) {
      //Open the apk.
      try {
        await OpenFile.open(_file.path);
      } catch (exception) {
        status = UpdateStatus.doneWithError;
        setState();
        return;
      }
    } else
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.done;
    setState();
  }
}
