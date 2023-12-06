import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

const Color primaryColor = Color(0xFF0D47A1);
const int nameMaxLength = 15;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
            primary: primaryColor, inversePrimary: primaryColor),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ApplicationWithIcon> _apps = [];
  List<double> _appsCacheSize = [];
  List<bool> _appsSelected = [];
  bool _areLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAppsInfo();
  }

  Future<void> _loadAppsInfo() async {
    DeviceApps.getInstalledApplications(
            includeAppIcons: true, includeSystemApps: false)
        .then((value) {
      setState(() {
        value.sort((a, b) => a.appName.compareTo(b.appName));
        _apps = value.map((e) => e as ApplicationWithIcon).toList();
        _appsCacheSize = List.filled(_apps.length, 0);
        _appsSelected = List.filled(_apps.length, true);

        _loadAppsCacheSize();
      });
    });
  }

  Future<void> _loadAppsCacheSize() async {
    setState(() {
      for (var app in _apps) {
        _getDirectorySize('/data/data/${app.packageName}/cache').then((value) {
          _appsCacheSize[_apps.indexOf(app)] = value / 1000000;
        });
      }
      _areLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _getAppBar(),
      body: _getPageContent(screenSize),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  _getAppBar() {
    return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Cache Cleaner',
            style: TextStyle(color: Colors.grey.shade200)),
        actions: [_getAppBarPopupMenu()]);
  }

  _getPageContent(Size screenSize) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _areLoaded
            ? Expanded(child: _buildAppList(screenSize))
            : const CircularProgressIndicator()
      ],
    ));
  }

  _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(Icons.delete, color: Colors.grey.shade400),
    );
  }

  _getAppBarPopupMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: Colors.grey.shade200),
      color: Colors.grey.shade900,
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.check_box,
                color: Colors.grey.shade200,
              ),
              const SizedBox(width: 10),
              Text(
                'Select all',
                style: TextStyle(color: Colors.grey.shade200, fontSize: 18),
              ),
            ],
          ),
          onTap: () => setState(
              () => _appsSelected.fillRange(0, _appsSelected.length, true)),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.check_box_outline_blank,
                color: Colors.grey.shade200,
              ),
              const SizedBox(width: 10),
              Text(
                'Deselect all',
                style: TextStyle(color: Colors.grey.shade200, fontSize: 18),
              ),
            ],
          ),
          onTap: () => setState(
              () => _appsSelected.fillRange(0, _appsSelected.length, false)),
        ),
      ],
    );
  }

  Widget _buildAppList(Size screenSize) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.01),
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (var app in _apps) _buildCard(screenSize, app),
              Container(height: screenSize.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Size screenSize, ApplicationWithIcon app) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.1,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 30, 30, 30),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              offset: Offset(0.0, 5.0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getAppDetails(app, screenSize),
            Transform.scale(
              scale: 1.25,
              child: StatefulBuilder(
                builder: (context, setState) => Checkbox(
                  checkColor: Colors.grey.shade400,
                  value: _appsSelected[_apps.indexOf(app)],
                  onChanged: (value) => setState(
                      () => _appsSelected[_apps.indexOf(app)] = value!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getAppDetails(ApplicationWithIcon app, Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.height * 0.02),
      child: Row(
        children: [
          Container(
            width: screenSize.height * 0.06,
            height: screenSize.height * 0.06,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  offset: Offset(0.0, 5.0),
                ),
              ],
              image: DecorationImage(
                image: Image.memory(app.icon).image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: screenSize.width * 0.025),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.appName.length > nameMaxLength
                    ? '${app.appName.substring(0, nameMaxLength)}...'
                    : app.appName,
                style: TextStyle(
                  color: Colors.grey.shade200,
                  fontSize: 20,
                ),
              ),
              Text(
                '${_appsCacheSize[_apps.indexOf(app)].toStringAsFixed(2)} MB',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<int> _getDirectorySize(String path) async {
    var files = await Directory(path).list(recursive: true).toList();
    var dirSize = files.fold(0, (int sum, file) => sum + file.statSync().size);
    return dirSize;
  }
}
