import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class InstalledApplication {
  late Application _app;
  late double cacheSize;
  late final ValueNotifier<bool> isSelected;
  late final Image icon;
  late bool isSystemApp;

  InstalledApplication(Application app) {
    _app = app;
    cacheSize = 0.0;
    isSelected = ValueNotifier(true);
    icon = Image.memory((app as ApplicationWithIcon).icon);
    isSystemApp = app.systemApp;

    // calculateCacheSize('/data/data/${app.packageName}/');
    // calculateCacheSize(
    // '/storage/emulated/0/Android/data/${app.packageName}/cache/');

    //   _getDirectorySize('/data/data/${app.packageName}/', true)
    //       .then((value) => cacheSize = value / 1000 / 1000);
  }

  Application get app => _app;

  Future calculateCacheSize(String dirPath) async {
    var files = await Directory(dirPath).list(recursive: true).toList();
    cacheSize = files.fold(0, (double sum, file) => sum + file.statSync().size);

    print('dirPath: $dirPath -> cacheSize: $cacheSize');

    cacheSize = cacheSize / 1000 / 1000;
  }

  // Future<double> _getDirectorySize(String path, bool isRecursive) async {
  //   double totalSize = 1;
  //   final entityList =
  //       await Directory(path).list(recursive: isRecursive).toList();

  //   await Future.forEach(entityList, (entity) async {
  //     if (entity is File) {
  //       final fileBytes = await File(entity.path).readAsBytes();
  //       totalSize += fileBytes.lengthInBytes;
  //     }
  //   });

  //   return totalSize;
  // }
}
