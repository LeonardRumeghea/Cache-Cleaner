import 'package:cache_cleaner/entities/installed_application.dart';
import 'package:cache_cleaner/entities/constants.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// --------------------------------- Variables ----------------------------------
  List<InstalledApplication> _apps = [];

  bool _areLoaded = false;
  final ValueNotifier<int> _selectedAppsCount = ValueNotifier(0);

  bool _sortAscending = true;
  bool _sortByName = true;
  bool _sortByCacheSize = false;

// --------------------------------- Init ----------------------------------
  @override
  void initState() {
    super.initState();

    _getPermission().then((value) => _init());
  }

  _getPermission() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    var externalStorageStatus = await Permission.manageExternalStorage.status;
    if (!externalStorageStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  _init() async {
    setState(() {
      _areLoaded = false;
      _apps.clear();
    });

    DeviceApps.getInstalledApplications(
            includeAppIcons: true, includeSystemApps: false)
        .then((value) {
      setState(() {
        // for (var app in value.map((e) => e as ApplicationWithIcon).toList()) {
        //   _apps.add(InstalledApplication(app));
        // }

        _apps = value.map((e) => InstalledApplication(e)).toList();

        _sortApps();

        _selectedAppsCount.value = _apps.length;
        _areLoaded = true;
      });
    });
  }

// --------------------------------- Build ----------------------------------
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _getAppBar(),
      body: _getPageContent(screenSize),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

// --------------------------------- AppBar Widgets ----------------------------------
  AppBar _getAppBar() {
    return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Cache Cleaner', style: TextStyle(color: primaryTextColor)),
        actions: [
          _getCheckAllButton(),
          _getSortPopupMenu(),
        ]);
  }

  ValueListenableBuilder<int> _getCheckAllButton() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedAppsCount,
      builder: (context, value, _) => IconButton(
        icon: Icon(
            value == _apps.length
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: primaryTextColor),
        onPressed: () => {
          for (var app in _apps) app.isSelected.value = value != _apps.length,
          _selectedAppsCount.value = value != _apps.length ? _apps.length : 0,
        },
      ),
    );
  }

  PopupMenuButton _getSortPopupMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.sort, color: primaryTextColor),
      color: Colors.grey.shade900,
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.sort_by_alpha,
                color: _sortByName ? primaryTextColor : unableTextColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Sort by name',
                style: TextStyle(
                    color: _sortByName ? primaryTextColor : unableTextColor,
                    fontSize: 18),
              ),
            ],
          ),
          onTap: () => setState(() => {
                _sortByName = true,
                _sortByCacheSize = false,
                _sortApps(),
              }),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.sort,
                color: _sortByCacheSize ? primaryTextColor : unableTextColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Sort by cache size',
                style: TextStyle(
                    color:
                        _sortByCacheSize ? primaryTextColor : unableTextColor,
                    fontSize: 18),
              ),
            ],
          ),
          onTap: () => setState(() => {
                _sortByName = false,
                _sortByCacheSize = true,
                _sortApps(),
              }),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                color: _sortAscending ? primaryTextColor : unableTextColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Sort ascending',
                style: TextStyle(
                    color: _sortAscending ? primaryTextColor : unableTextColor,
                    fontSize: 18),
              ),
            ],
          ),
          onTap: () => setState(() => {
                _sortAscending = true,
                _sortApps(),
              }),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                color: _sortAscending ? unableTextColor : primaryTextColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Sort descending',
                style: TextStyle(
                    color: _sortAscending ? unableTextColor : primaryTextColor,
                    fontSize: 18),
              ),
            ],
          ),
          onTap: () => setState(() => {
                _sortAscending = false,
                _sortApps(),
              }),
        ),
      ],
    );
  }

// --------------------------------- Floating Button ----------------------------------
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: implement cache cleaning

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleaned successfully!'),
            backgroundColor: successColor,
          ),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(Icons.delete, color: secondaryTextColor),
    );
  }

// --------------------------------- Page Content ----------------------------------
  Widget _getPageContent(Size screenSize) {
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

  Widget _buildAppList(Size screenSize) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.01),
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: RefreshIndicator(
          onRefresh: () => _init(),
          child: ListView.builder(
            itemCount: _apps.length + 1,
            itemBuilder: (context, index) => index == _apps.length
                ? Container(height: screenSize.height * 0.1)
                : _buildCard(screenSize, _apps[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Size screenSize, InstalledApplication app) {
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
                builder: (context, setState) => ValueListenableBuilder<bool>(
                  valueListenable: app.isSelected,
                  builder: (context, value, _) => Checkbox(
                    checkColor: secondaryTextColor,
                    value: app.isSelected.value,
                    onChanged: (value) => setState(() => {
                          app.isSelected.value = value!,
                          _selectedAppsCount.value +=
                              (app.isSelected.value ? 1 : -1),
                        }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAppDetails(InstalledApplication app, Size screenSize) {
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
                image: app.icon.image,
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
                app.app.appName.length > nameMaxLength
                    ? '${app.app.appName.substring(0, nameMaxLength)}...'
                    : app.app.appName,
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 20,
                ),
              ),
              Text(
                '${app.cacheSize.toStringAsFixed(2)} MB',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// --------------------------------- Utilities ----------------------------------
  void _sortApps() {
    if (_sortByName) {
      _apps.sort((a, b) => a.app.appName.compareTo(b.app.appName));
    } else if (_sortByCacheSize) {
      _apps.sort((a, b) => a.cacheSize.compareTo(b.cacheSize));
    }

    if (!_sortAscending) {
      _apps = _apps.reversed.toList();
    }
  }
}
