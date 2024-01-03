import 'dart:math';

import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class InstalledApplication {
  late String appName;
  late String packageName;
  late double cacheSize;
  late final Image icon;
  late bool isSystemApp;

  late final ValueNotifier<bool> isSelected;

  InstalledApplication(Application app) {
    appName = app.appName;
    packageName = app.packageName;
    cacheSize = 0.0;
    icon = Image.memory((app as ApplicationWithIcon).icon);
    isSystemApp = app.systemApp;
    isSelected = ValueNotifier(true);

    calculateCacheSize();

    // '/data/data/${app.packageName}/'
    // '/storage/emulated/0/Android/data/${app.packageName}/cache/'
  }

  Future calculateCacheSize() async {
    cacheSize = Random().nextDouble() * 100;

    // String dirPath =
    //     '/storage/emulated/0/Android/data/${app.packageName}/cache/';
    // var files = await Directory(dirPath).list(recursive: true).toList();
    // cacheSize = files.fold(0, (double sum, file) => sum + file.statSync().size);

    // cacheSize = cacheSize / 1000 / 1000;
  }

  double clearCache() {
    double clearedSize = cacheSize;
    cacheSize = 0.0;
    return clearedSize;
  }
}
