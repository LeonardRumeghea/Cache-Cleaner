import 'package:device_apps/device_apps.dart';

class InstalledApplication {
  late ApplicationWithIcon _app;
  late double cacheSize;
  late bool isSelected;

  InstalledApplication(ApplicationWithIcon app) {
    _app = app;
    cacheSize = 0.0;
    isSelected = true;
  }

  ApplicationWithIcon get app => _app;
}
