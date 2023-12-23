import 'package:cache_cleaner/entities/installed_application.dart';
import 'package:cache_cleaner/entities/constants.dart';
import 'package:cache_cleaner/services/theme_changer.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// --------------------------------- Variables ----------------------------------
  List<InstalledApplication> _allApps = [];
  List<InstalledApplication> _appsToDisplay = [];

  bool _areLoaded = false;
  final ValueNotifier<int> _selectedAppsCount = ValueNotifier(0);

  bool _sortAscending = true;
  bool _sortByName = true;
  bool _sortByCacheSize = false;

  bool _includeSystemApps = false;

// --------------------------------- Init ----------------------------------
  @override
  void initState() {
    super.initState();

    _getPermission().then((value) => _init());
  }

  _getPermission() async {
    var externalStorageStatus = await Permission.manageExternalStorage.status;
    print('Manage external storage permision:$externalStorageStatus');
    if (!externalStorageStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  _init() async {
    setState(() {
      _areLoaded = false;
      _appsToDisplay.clear();
    });

    DeviceApps.getInstalledApplications(
            includeAppIcons: true, includeSystemApps: true)
        .then((value) {
      setState(() {
        _allApps = value.map((e) => InstalledApplication(e)).toList();
        _includeSystemAppsChanged(_includeSystemApps);

        _selectedAppsCount.value = _appsToDisplay.length;
        _areLoaded = true;
      });
    });
  }

  _includeSystemAppsChanged(bool value) {
    setState(() {
      _includeSystemApps = value;
      _appsToDisplay =
          _allApps.where((element) => element.isSystemApp == value).toList();
      for (var element in _appsToDisplay) {
        element.isSelected.value = true;
      }
      _selectedAppsCount.value = _appsToDisplay.length;
      _sortApps();
    });
  }

// --------------------------------- Build ----------------------------------
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ThemeChanger themeChanger = Provider.of<ThemeChanger>(context);

    return Scaffold(
      appBar: _getAppBar(),
      body: _getPageContent(screenSize),
      floatingActionButton: _buildFloatingActionButton(),
      drawer: _getDrawer(themeChanger),
    );
  }

// --------------------------------- AppBar Widgets ----------------------------------
  AppBar _getAppBar() {
    return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Cache Cleaner', style: TextStyle(color: appbarTextColor)),
        iconTheme: IconThemeData(color: appbarTextColor),
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
            value == _appsToDisplay.length
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: appbarTextColor),
        onPressed: () => {
          for (var app in _appsToDisplay)
            app.isSelected.value = value != _appsToDisplay.length,
          _selectedAppsCount.value =
              value != _appsToDisplay.length ? _appsToDisplay.length : 0,
        },
      ),
    );
  }

  PopupMenuButton _getSortPopupMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.sort, color: appbarTextColor),
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
                    fontSize: popupMenuTextSize),
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
                    fontSize: popupMenuTextSize),
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
                    fontSize: popupMenuTextSize),
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
                    fontSize: popupMenuTextSize),
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
          SnackBar(
            // Text: x MB of cache cleaned
            content: Text(
              '${_getSelectedCacheSize().toStringAsFixed(2)} MB of cache memory was removed! 😁',
              style: TextStyle(
                  color: appbarTextColor, fontSize: secondaryTextSize),
            ),
            backgroundColor: successColor,
          ),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(Icons.delete, color: appbarTextColor),
    );
  }

  Widget _getDrawer(ThemeChanger themeChanger) {
    return Drawer(
      elevation: 1.5,
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              border: Border(
                bottom: Divider.createBorderSide(context,
                    color: Colors.transparent, width: 0.0),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Cache Cleaner',
                style: TextStyle(color: appbarTextColor, fontSize: 32),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.apps, color: primaryTextColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Include System Apps',
                        style: TextStyle(color: primaryTextColor),
                      ),
                      Switch(
                        value: _includeSystemApps,
                        onChanged: (value) => {
                          _includeSystemAppsChanged(value),
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.dark_mode, color: primaryTextColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dark Mode',
                        style: TextStyle(color: primaryTextColor),
                      ),
                      Switch(
                        value: themeChanger.getTheme() == darkTheme,
                        onChanged: (_) =>
                            setState(() => themeChanger.toggleTheme()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: drawerBottomHeight(context),
            child: ListTile(
              leading: Icon(Icons.info, color: primaryTextColor),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'About',
                    style: TextStyle(color: primaryTextColor),
                  ),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ],
              ),
              onTap: () => {},
            ),
          ),
        ],
      ),
    );
  }

// --------------------------------- Page Content ----------------------------------
  Widget _getPageContent(Size screenSize) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _areLoaded
            ? Expanded(child: _buildAppList(screenSize))
            : _showLoadingAnimation(),
      ],
    ));
  }

  Widget _buildAppList(Size screenSize) {
    return Padding(
      padding: EdgeInsets.only(top: cardVerticalPadding(context)),
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: RefreshIndicator(
          onRefresh: () => _init(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _appsToDisplay.length + 1,
            itemBuilder: (context, index) => index == _appsToDisplay.length
                ? Container(height: cardHeight(context))
                : _buildCard(screenSize, _appsToDisplay[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Size screenSize, InstalledApplication app) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: cardVerticalPadding(context),
        horizontal: cardHorizontalPadding(context),
      ),
      child: Container(
        width: cardWidth(context),
        height: cardHeight(context),
        decoration: BoxDecoration(
          color: cardGreyColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [cardBoxShadow],
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
                    checkColor: appbarTextColor,
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
              width: cardIconSize(context),
              height: cardIconSize(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: const [cardBoxShadow],
                image: DecorationImage(
                  image: app.icon.image,
                  fit: BoxFit.cover,
                ),
              ),
              child: GestureDetector(
                onTap: () => app.app.openSettingsScreen(),
              )),
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
                  fontSize: primaryTextSize,
                ),
              ),
              Text(
                '${app.cacheSize.toStringAsFixed(2)} MB',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: secondaryTextSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showLoadingAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: appbarTextColor),
        const SizedBox(width: 20),
        Text(
          'Loading...',
          style: TextStyle(color: appbarTextColor, fontSize: 20),
        ),
      ],
    );
  }

// --------------------------------- Utilities ----------------------------------
  void _sortApps() {
    if (_sortByName) {
      _appsToDisplay.sort((a, b) => a.app.appName.compareTo(b.app.appName));
    } else if (_sortByCacheSize) {
      _appsToDisplay.sort((a, b) => a.cacheSize.compareTo(b.cacheSize));
    }

    if (!_sortAscending) {
      _appsToDisplay = _appsToDisplay.reversed.toList();
    }
  }

  double _getSelectedCacheSize() {
    double size = 0.0;
    for (var app in _appsToDisplay) {
      if (app.isSelected.value) {
        size += app.cacheSize;
      }
    }
    return size;
  }
}
