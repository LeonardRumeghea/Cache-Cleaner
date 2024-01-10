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
  final List<InstalledApplication> _systemApps = [];
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
    if (!externalStorageStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  _init() async {
    setState(() {
      _areLoaded = false;
    });

    DeviceApps.getInstalledApplications(
            includeAppIcons: true, includeSystemApps: true)
        .then((value) {
      setState(() {
        _systemApps.addAll(value
            .where((app) => app.systemApp)
            .map((app) => InstalledApplication(app)));
        _appsToDisplay.addAll(value
            .where((app) => !app.systemApp)
            .map((app) => InstalledApplication(app)));

        _includeSystemAppsChanged(_includeSystemApps);

        _areLoaded = true;
      });
    });
  }

  _includeSystemAppsChanged(bool value) {
    setState(() {
      _includeSystemApps = value;

      if (_includeSystemApps) {
        _appsToDisplay.addAll(_systemApps);
      } else {
        _appsToDisplay.removeWhere((element) => element.isSystemApp);
      }

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

    return !_areLoaded
        ? _showLoadingAnimation()
        : Scaffold(
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
        title: const Text('Cache Cleaner'),
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
          color: primaryTextColor,
        ),
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
      icon: Icon(Icons.sort, color: primaryTextColor),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.sort_by_alpha,
                color: _sortByName
                    ? Theme.of(context).colorScheme.primary
                    : unableTextColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Sort by name',
                style: TextStyle(
                  color: _sortByName ? primaryTextColor : unableTextColor,
                  fontSize: popupMenuTextSize,
                ),
              ),
            ],
          ),
          onTap: () => setState(() =>
              {_sortByName = true, _sortByCacheSize = false, _sortApps()}),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.sort,
                color: _sortByCacheSize
                    ? Theme.of(context).colorScheme.primary
                    : unableTextColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Sort by cache size',
                style: TextStyle(
                  color: _sortByCacheSize ? primaryTextColor : unableTextColor,
                  fontSize: popupMenuTextSize,
                ),
              ),
            ],
          ),
          onTap: () => setState(() =>
              {_sortByName = false, _sortByCacheSize = true, _sortApps()}),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                color: _sortAscending
                    ? Theme.of(context).colorScheme.primary
                    : unableTextColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Sort ascending',
                style: TextStyle(
                  color: _sortAscending ? primaryTextColor : unableTextColor,
                  fontSize: popupMenuTextSize,
                ),
              ),
            ],
          ),
          onTap: () => setState(() => {_sortAscending = true, _sortApps()}),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                color: _sortAscending
                    ? unableTextColor
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Sort descending',
                style: TextStyle(
                  color: _sortAscending ? unableTextColor : primaryTextColor,
                  fontSize: popupMenuTextSize,
                ),
              ),
            ],
          ),
          onTap: () => setState(() => {_sortAscending = false, _sortApps()}),
        ),
      ],
    );
  }

// --------------------------------- Floating Button ----------------------------------
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        double clearedCache = _appsToDisplay
            .where((app) => app.isSelected.value)
            .map((app) => app.clearCache())
            .fold(0.0, (sum, value) => sum + value);

        _sortApps();

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${(clearedCache / 1000).toStringAsFixed(2)} GB of cache memory was removed!',
              style: TextStyle(
                  color: textColorByBackground(
                      Theme.of(context).colorScheme.inversePrimary),
                  fontSize: secondaryTextSize),
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        );
      },
      child: const Icon(Icons.delete),
    );
  }

  Widget _getDrawer(ThemeChanger themeChanger) {
    return Drawer(
      elevation: 1.5,
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              border: Border(
                bottom: Divider.createBorderSide(context,
                    color: Colors.transparent, width: 0.0),
              ),
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cache Cleaner', style: TextStyle(fontSize: 32)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.apps),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Include System Apps'),
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
                  leading: const Icon(Icons.dark_mode),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dark Mode'),
                      Switch(
                        value: themeChanger.isDarkMode(),
                        onChanged: (_) => themeChanger.toggleTheme(),
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
              leading: const Icon(Icons.info),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('About'),
                  Text(
                    "Version 1.0.1",
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
        children: [Expanded(child: _buildAppList(screenSize))],
      ),
    );
  }

  Widget _buildAppList(Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: RefreshIndicator(
        onRefresh: () => _recalculateSelectedAppsCacheSize(),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _appsToDisplay.length + 1,
          itemBuilder: (context, index) => index == _appsToDisplay.length
              ? Container(height: cardHeight(context))
              : _buildCard(screenSize, _appsToDisplay[index], index),
        ),
      ),
    );
  }

  Widget _buildCard(Size screenSize, InstalledApplication app, int idx) {
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
                onTap: () => DeviceApps.openAppSettings(app.packageName),
              )),
          SizedBox(width: screenSize.width * 0.025),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.appName.length > nameMaxLength
                    ? '${app.appName.substring(0, nameMaxLength)}...'
                    : app.appName,
                style: TextStyle(fontSize: primaryTextSize),
              ),
              Text(
                '${app.cacheSize.toStringAsFixed(2)} MB',
                style: TextStyle(
                    color: secondaryTextColor, fontSize: secondaryTextSize),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showLoadingAnimation() {
    return Stack(
      children: [
        Center(
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.height * 0.1,
            child: Image.asset('assets/icons/cache_cleaner_icon.png'),
          ),
        ),
        Center(
          child: ScaleTransition(
            scale: const AlwaysStoppedAnimation(4.9),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        )
      ],
    );
  }

// --------------------------------- Utilities ----------------------------------
  void _sortApps() {
    if (_sortByName) {
      _appsToDisplay.sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    } else if (_sortByCacheSize) {
      _appsToDisplay.sort((a, b) => a.cacheSize.compareTo(b.cacheSize));
    }

    if (!_sortAscending) {
      _appsToDisplay = _appsToDisplay.reversed.toList();
    }
  }

  Future<void> _recalculateSelectedAppsCacheSize() async {
    return Future.wait(_appsToDisplay
            .where((element) => element.isSelected.value)
            .map((e) => e.calculateCacheSize()))
        .then((value) => setState(() => _sortApps()));
  }
}
