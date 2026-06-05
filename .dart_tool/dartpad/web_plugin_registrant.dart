// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:package_info_plus/src/package_info_plus_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:wakelock_plus/src/wakelock_plus_web_plugin.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  PackageInfoPlusWebPlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  WakelockPlusWebPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
