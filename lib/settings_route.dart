import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/icons/daily_trojan_icons.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/section_route.dart';
import 'package:dailytrojan/utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

WebViewEnvironment? webViewEnvironment;

class SettingsRoute extends StatelessWidget {
  var debugStrings = DebugService.getAllDebugStrings();

  PackageInfo? packageInfo;

  Future<void> _loadPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  void openThemeDialog() async {}
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    final dialogHeaderStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        height: .8);
    final subStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onSurface, fontFamily: "Inter");
    final bool isDarkMode = theme.brightness == Brightness.dark;

    _loadPackageInfo();

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: AnimatedTitleScrollView(
          collapsingSliverAppBar: CollapsingSliverAppBar(
            backgroundColor: theme.colorScheme.surfaceContainerLowest,
            title: Text(
              "Settings",
              style: headerStyle,
            ),
          ),
          children: [
            SettingsButton(
                onTap: () {
                  showDialog<ThemeMode>(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: Text('Theme', style: dialogHeaderStyle),
                          children: <Widget>[
                            RadioGroup(
                                groupValue: appState.themeMode,
                                onChanged: (ThemeMode? value) {
                                  Navigator.pop(context);
                                  appState
                                      .setThemeMode(value ?? ThemeMode.system);
                                },
                                child: Column(children: [
                                  RadioListTile<ThemeMode>(
                                      title: Text("System Default"),
                                      value: ThemeMode.system),
                                  RadioListTile<ThemeMode>(
                                      title: Text("Dark"),
                                      value: ThemeMode.dark),
                                  RadioListTile<ThemeMode>(
                                      title: Text("Light"),
                                      value: ThemeMode.light),
                                ])),
                          ],
                        );
                      });
                },
                showArrow: false,
                icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                text: "Theme"),
            Padding(
              padding: horizontalContentPadding,
              child: Divider(height: 1),
            ),
            SettingsButton(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideOverPageRoute(child: NotificationsSettingsRoute()),
                  );
                },
                icon: Icons.notifications,
                text: "Notifications"),
            Padding(
              padding: horizontalContentPadding,
              child: Divider(height: 1),
            ),
            SettingsButton(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideOverPageRoute(
                        child: AppInfoRoute(
                      packageInfo: packageInfo!,
                    )),
                  );
                },
                icon: Icons.info_outline,
                text: "App Info"),
          ]),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton(
      {super.key,
      required this.onTap,
      required this.text,
      required this.icon,
      this.showArrow = true});

  final VoidCallback onTap;
  final String text;
  final IconData icon;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    final subStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onSurface, fontFamily: "Inter");
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0)
            .add(horizontalContentPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.onSurface,
                ),
                Text(
                  text,
                  style: subStyle,
                ),
              ],
            ),
            if (this.showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
              )
          ],
        ),
      ),
    );
  }
}

class NotificationsSettingsRoute extends StatelessWidget {
  List<Post> sectionPosts = [];

  int sectionID = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);

    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: Placeholder(),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
        title: Text(
          "Notifications",
          style: headlineStyle,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class AppInfoRoute extends StatelessWidget {
  List<Post> sectionPosts = [];

  int sectionID = 0;
  final PackageInfo packageInfo;

  AppInfoRoute({super.key, required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final infoStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14.0,
        fontFamily: "Inter");
    final headerStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onSurface, fontFamily: "Inter");
    

    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0)
                    .add(horizontalContentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Version",
                        style: headerStyle),
                    Text(
                        "${packageInfo.version} (${packageInfo.buildNumber})",
                        style: infoStyle),
                  ],
                ),
              ),
              onTap: () {
                copyToClipboard(
                    "${packageInfo.version} (${packageInfo.buildNumber})",
                    context);
              },
            ),
            Padding(
              padding: horizontalContentPadding,
              child: Divider(height: 1),
            ),
            InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0)
                    .add(horizontalContentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "AID",
                        style: headerStyle),
                    Text(
                        "${PreferencesService.getAID().replaceAll("-", "")}",
                        style: infoStyle),
                  ],
                ),
              ),
              onTap: () {
                copyToClipboard(PreferencesService.getAID(), context);
              },
            ),
            Padding(
              padding: horizontalContentPadding,
              child: Divider(height: 1),
            ),
            InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0)
                    .add(horizontalContentPadding),
                child: Row(
                  children: [
                    Text("Licenses", style: headerStyle),
                  ],
                ),
              ),
              onTap: () {
                showLicense(context,
                    "Version ${packageInfo.version} (${packageInfo.buildNumber})");
              },
            ),
            Padding(
              padding: horizontalContentPadding,
              child: Divider(height: 1),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0)
                  .add(horizontalContentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Copyright", style: headerStyle),
                    Text(
                        "© ${DateTime.now().year} Daily Trojan. All rights reserved.",
                        style: infoStyle),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
        title: Text(
          "App Information",
          style: headlineStyle,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

showLicense(BuildContext context, String version) {
  final theme = Theme.of(context);
  final headlineStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onSurface,
      fontFamily: "SourceSerif4",
      fontWeight: FontWeight.bold);
      // Navigator.of(context).push(
      //   SlideOverPageRoute(
      //     child: LicensePage(
      //     ),
      //   ),
      // );
      // return;
  Navigator.push(
    context,
    SlideOverPageRoute(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: Theme(
            data: Theme.of(context).copyWith(cardColor: theme.colorScheme.surfaceContainerLowest),
            child: PackagesView(
                isLateral: false, selectedId: ValueNotifier<int?>(null))),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surfaceContainerLowest,
          surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
          title: Text(
            "Licenses",
            style: headlineStyle,
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: theme.colorScheme.outlineVariant,
              height: 1.0,
            ),
          ),
        ),
      ),
    ),
  );
}

class _LicenseData {
  final List<LicenseEntry> licenses = <LicenseEntry>[];
  final Map<String, List<int>> packageLicenseBindings = <String, List<int>>{};
  final List<String> packages = <String>[];

  // Special treatment for the first package since it should be the package
  // for delivered application.
  String? firstPackage;

  void addLicense(LicenseEntry entry) {
    // Before the license can be added, we must first record the packages to
    // which it belongs.
    for (final String package in entry.packages) {
      _addPackage(package);
      // Bind this license to the package using the next index value. This
      // creates a contract that this license must be inserted at this same
      // index value.
      packageLicenseBindings[package]!.add(licenses.length);
    }
    licenses.add(entry); // Completion of the contract above.
  }

  /// Add a package and initialize package license binding. This is a no-op if
  /// the package has been seen before.
  void _addPackage(String package) {
    if (!packageLicenseBindings.containsKey(package)) {
      packageLicenseBindings[package] = <int>[];
      firstPackage ??= package;
      packages.add(package);
    }
  }

  /// Sort the packages using some comparison method, or by the default manner,
  /// which is to put the application package first, followed by every other
  /// package in case-insensitive alphabetical order.
  void sortPackages([int Function(String a, String b)? compare]) {
    packages.sort(
      compare ??
          (String a, String b) {
            // Based on how LicenseRegistry currently behaves, the first package
            // returned is the end user application license. This should be
            // presented first in the list. So here we make sure that first package
            // remains at the front regardless of alphabetical sorting.
            if (a == firstPackage) {
              return -1;
            }
            if (b == firstPackage) {
              return 1;
            }
            return a.toLowerCase().compareTo(b.toLowerCase());
          },
    );
  }
}

class PackagesView extends StatefulWidget {
  const PackagesView({required this.isLateral, required this.selectedId});

  final bool isLateral;
  final ValueNotifier<int?> selectedId;

  @override
  _PackagesViewState createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  final Future<_LicenseData> licenses = LicenseRegistry.licenses
      .fold<_LicenseData>(
        _LicenseData(),
        (_LicenseData prev, LicenseEntry license) => prev..addLicense(license),
      )
      .then((_LicenseData licenseData) => licenseData..sortPackages());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LicenseData>(
      future: licenses,
      builder: (BuildContext context, AsyncSnapshot<_LicenseData> snapshot) {
        return LayoutBuilder(
          key: ValueKey<ConnectionState>(snapshot.connectionState),
          builder: (BuildContext context, BoxConstraints constraints) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  assert(() {
                    FlutterError.reportError(
                      FlutterErrorDetails(
                        exception: snapshot.error!,
                        stack: snapshot.stackTrace,
                        context:
                            ErrorDescription('while decoding the license file'),
                      ),
                    );
                    return true;
                  }());
                  return Center(child: Text(snapshot.error.toString()));
                }
                _initDefaultDetailPage(snapshot.data!, context);
                return ValueListenableBuilder<int?>(
                  valueListenable: widget.selectedId,
                  builder: (BuildContext context, int? selectedId, Widget? _) {
                    return Center(
                      child: Material(
                        color: Theme.of(context).cardColor,
                        elevation: 4.0,
                        child: _packagesList(
                          context,
                          selectedId,
                          snapshot.data!,
                          widget.isLateral,
                        ),
                      ),
                    );
                  },
                );
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Material(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                );
            }
          },
        );
      },
    );
  }

  void _initDefaultDetailPage(_LicenseData data, BuildContext context) {
    if (data.packages.isEmpty) {
      return;
    }
    final String packageName = data.packages[widget.selectedId.value ?? 0];
    final List<int> bindings = data.packageLicenseBindings[packageName]!;
    // _MasterDetailFlow.of(context).setInitialDetailPage(
    //   _DetailArguments(
    //     packageName,
    //     bindings.map((int i) => data.licenses[i]).toList(growable: false),
    //   ),
    // );
  }

  Widget _packagesList(
    final BuildContext context,
    final int? selectedId,
    final _LicenseData data,
    final bool drawSelection,
  ) {
    return ListView.builder(
      padding: bottomAppBarPadding,
      itemCount: data.packages.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return EmptyWidget();
        }
        final int packageIndex = index - 1;
        final String packageName = data.packages[packageIndex];
        final List<int> bindings = data.packageLicenseBindings[packageName]!;
        return _PackageListTile(
          packageName: packageName,
          index: packageIndex,
          isSelected: drawSelection && packageIndex == (selectedId ?? 0),
          numberLicenses: bindings.length,
          onTap: () {
            widget.selectedId.value = packageIndex;
            print(packageName);
            var licenses = bindings
                .map((int i) => data.licenses[i])
                .toList(growable: false);
            Navigator.push(
              context,
              SlideOverPageRoute(
                  child: LicenseRoute(
                packageName: packageName,
                licenses: licenses,
              )),
            );
          },
        );
      },
    );
  }
}

class _PackageListTile extends StatelessWidget {
  const _PackageListTile({
    required this.packageName,
    this.index,
    required this.isSelected,
    required this.numberLicenses,
    this.onTap,
  });

  final String packageName;
  final int? index;
  final bool isSelected;
  final int numberLicenses;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: isSelected
          ? Theme.of(context).highlightColor
          : Theme.of(context).cardColor,
      child: ListTile(
        title: Text(packageName),
        subtitle: Text(MaterialLocalizations.of(context)
            .licensesPackageDetailText(numberLicenses)),
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}

class LicenseRoute extends StatelessWidget {
  List<Post> sectionPosts = [];

  int sectionID = 0;
  final String packageName;
  final List<LicenseEntry> licenses;

  LicenseRoute({super.key, required this.packageName, required this.licenses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final infoStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14.0,
        fontFamily: "Inter");
    final headerStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
        fontFamily: "Inter");
        for (var license in licenses) {
          print(license.paragraphs);
          license.paragraphs.forEach((paragraph) {
            print(paragraph.text);
          });
        }

    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.separated(
                padding: bottomAppBarPadding,
                itemCount: licenses.length,
                separatorBuilder: (BuildContext context, int index) =>
                    Padding(
                      padding: horizontalContentPadding,
                      child: Divider(),
                    ),
                itemBuilder: (BuildContext context, int index) {
                  final LicenseEntry license = licenses[index];
                  return Padding(
                    padding: horizontalContentPadding.add(
                        const EdgeInsets.symmetric(vertical: 8.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: license.paragraphs
                          .map((LicenseParagraph paragraph) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  paragraph.text,
                                  style: infoStyle,
                                ),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
        title: Text(
          packageName,
          style: headlineStyle,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
