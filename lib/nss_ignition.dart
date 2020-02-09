import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_app.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/models/spark.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class NssIgnitionWidget extends StatelessWidget {
  final Layout layoutScreenSet;
  final bool useMockData;

  NssIgnitionWidget({Key key, @required this.layoutScreenSet, this.useMockData = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _spark(context),
      builder: (context, AsyncSnapshot<Spark> snapshot) {
        if (snapshot.hasData) {
          // Is this screen set platform aware? Register value.
          final platformAware = snapshot.data.platformAware ?? false;
          registry.isPlatformAware = platformAware;
          nssLogger.d('Using Cupertino platform for iOS: ${platformAware.toString()}');

          // Check initial route. If not set in the provided markup choose the first provided screen.
          final initialRoute = snapshot.data.markup.initialRoute ?? snapshot.data.markup.screens.entries.first.value.id;
          if (initialRoute == null) {
            return NssErrorWidget.routeMissMatch();
          }
          nssLogger.d('Initial route = $initialRoute');

          // Create application widget.
          return NssApp(
            layoutScreenSet,
            snapshot.data.markup,
            initialRoute,
            useMockData,
          );
        } else {
          return Container(
            color: Color(0xFFFFFFFF),
          );
        }
      },
    );
  }

  Future<Spark> _spark(context) async {
    var fetchData = useMockData
        ? await AssetUtils.jsonMapFromAssets('assets/mock_1.json')
        : await registry.channels.mainChannel.invokeMethod<Map<dynamic, dynamic>>(NssMainAction.ignition.action);
    return compute(ignite, fetchData);
  }
}

/// Top level function for the spark computation.
/// Compute can only take top-level functions in order to correctly open the isolate.
Spark ignite(Map<dynamic, dynamic> map) {
  return Spark.fromJson(map.cast<String, dynamic>());
}
