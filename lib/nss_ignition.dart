import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:provider/provider.dart';

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class NssIgnitionWidget extends StatelessWidget {
  final Layout layoutScreenSet;
  final bool useMockData;

  NssIgnitionWidget({Key key, @required this.layoutScreenSet, this.useMockData = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: requestMarkup(context),
      builder: (context, AsyncSnapshot<Map<dynamic, dynamic>> snapshot) {
        if (snapshot.hasData) {
          debugPrint('Init engine has data');

          // Is this screen set platform aware?
          final platformAware = snapshot.data['platformAware'] ?? false;

          debugPrint('Using Cupertino platform for iOS: ${platformAware.toString()}');

          // Parse markup and provide App widget.
          Main parsed = Main.fromJson(snapshot.data['markup'].cast<String, dynamic>());

          // Check initial route. If not set in the provided markup choose the first provided screen.
          final initialRoute =
              snapshot.data['markup']['initialRoute'] ?? parsed.screens.entries.first.value.id;
          if (initialRoute == null) {
            return NssErrorWidget.routeMissMatch();
          }
          debugPrint('Initial route = $initialRoute');

          // Create application widget.
          return createAppWidget(
            platformAware,
            parsed,
            initialRoute,
            layoutScreenSet,
          );
        } else {
          return Container(
            color: Color(0xFFFFFFFF),
          );
        }
      },
    );
  }

  /// Begin engine initialization process with requesting the data from the native library.
  Future<Map<dynamic, dynamic>> requestMarkup(context) {
    return useMockData
        ? AssetUtils.jsonMapFromAssets('assets/mock_1.json')
        : getRegistryBloc(context)
            .channels
            .mainChannel
            .invokeMethod<Map<dynamic, dynamic>>(NssAction.ignition.action);
  }

  @visibleForTesting
  NssRegistryBloc getRegistryBloc(context) {
    return Provider.of<NssRegistryBloc>(context);
  }

  /// Create main AppWidget according to initialization data.
  /// In case [platformAware] property is true, application will be determined via device platform.
  Widget createAppWidget(platformAware, markup, initialRoute, layout) {
    // Currently ignoring platform awareness.
    return (platformAware && Platform.isIOS)
        ? NativeScreensCupertinoApp(markup, initialRoute, layout)
        : NativeScreensMaterialApp(markup, initialRoute, layout);
  }
}

typedef Widget Layout(Main main, String initialRoute);

/// Customized MaterialApp widget for Android/Global devices.
class NativeScreensMaterialApp extends MaterialApp {
  final Layout layout;
  final Main markup;
  final String initialRoute;

  NativeScreensMaterialApp(
    this.markup,
    this.initialRoute,
    this.layout,
  );

  @override
  Widget get home => layout(markup, initialRoute);
}

/// Customized CupertinoApp for iOS devices.
class NativeScreensCupertinoApp extends CupertinoApp {
  final Layout layout;
  final Main markup;
  final String initialRoute;

  NativeScreensCupertinoApp(
    this.markup,
    this.initialRoute,
    this.layout,
  );

  @override
  Widget get home => layout(markup, initialRoute);
}
