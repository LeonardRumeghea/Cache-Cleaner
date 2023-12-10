import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class InstalledApplication {
  late Application _app;
  late double cacheSize;
  late final ValueNotifier<bool> isSelected;
  late final Image icon;

  InstalledApplication(Application app) {
    _app = app;
    cacheSize = 0.0;
    isSelected = ValueNotifier(true);
    icon = Image.memory((app as ApplicationWithIcon).icon);
  }

  Application get app => _app;
}
