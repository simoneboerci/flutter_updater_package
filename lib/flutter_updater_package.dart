library flutter_updater_package;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  static int recived;
  static int total;

  static Future<void> checkUpdates(
      String currentVersion, String latestVersionPath, String updateUrlPath,
      {bool sampleUpdate = false, Function setState, int delay = 1}) async {
    status = UpdateStatus.checkingVersions;
    setState();

    var _latestVersion;

    final _dio = Dio();

    if (!sampleUpdate) {
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

    if (_latestVersion > _currentVersion) {
      status = UpdateStatus.updateFound;
      setState();
    } else {
      status = UpdateStatus.upToDate;
      setState();
      return;
    }

    if(sampleUpdate)
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.checkingPermissions;
    setState();

    final _storagePermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (_storagePermission != PermissionStatus.granted)
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    if (_storagePermission != PermissionStatus.granted) {
      status = UpdateStatus.doneWithError;
      setState();
      return;
    }

    Directory _fileDirectory;

    if (!sampleUpdate) {
      final _directory = await getExternalStorageDirectory();
      _fileDirectory = Directory("${_directory.path}/./update");

      if (!await _fileDirectory.exists()) {
        try {
          _fileDirectory.create();
        } catch (exception) {
          status = UpdateStatus.doneWithError;
          setState();
          return;
        }
      }
    }else
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.downloading;
    setState();

    var _updateUrl;

    if (!sampleUpdate) {
      try {
        _updateUrl = await _dio.get(updateUrlPath);
      } catch (exception) {
        status = UpdateStatus.doneWithError;
        setState();
        return;
      } finally {
        _dio.close();
      }
    }else
      await Future.delayed(Duration(seconds: delay));

    const String updateFileName = "update";

    if (!sampleUpdate) {
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
    }else
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.writing;
    setState();

    File _file;

    if (!sampleUpdate) {
      _file = File("${_fileDirectory.path}/$updateFileName.apk");

      if (!await _file.exists()) {
        try {
          _file.create();
        } catch (exception) {
          status = UpdateStatus.doneWithError;
          setState();
          return;
        }
      }
    }else
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.opening;
    setState();

    if (!sampleUpdate) {
      try {
        await OpenFile.open(_file.path);
      } catch (exception) {
        status = UpdateStatus.doneWithError;
        setState();
        return;
      }
    }else
      await Future.delayed(Duration(seconds: delay));

    status = UpdateStatus.done;
    setState();
  }
}
