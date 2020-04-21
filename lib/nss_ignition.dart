import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_app.dart';
import 'package:gigya_native_screensets_engine/models/spark.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_router.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class NssIgnitionWidget extends StatelessWidget {
  final IgnitionWorker worker;
  final NssConfig config;
  final NssChannels channels;
  final Router router;

  NssIgnitionWidget({
    Key key,
    @required this.worker,
    @required this.config,
    @required this.channels,
    @required this.router,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: worker.spark(),
      builder: (context, AsyncSnapshot<Spark> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          nssLogger.d('ignition - state - done');
          return prepareApp(snapshot.data);
        } else {
          return onPreparingApp();
        }
      },
    );
  }

  /// Commence Flutter application buildup according to provided [Spark] markup.
  @visibleForTesting
  Widget prepareApp(Spark spark) {
    config.main = spark.markup;
    config.isPlatformAware = spark.platformAware ?? false;
    // Notify native that we are ready to display. Pre-warm up done.
    readyForDisplay();
    return Container(
      color: Colors.white,
      child: NssApp(config: config, router: router),
    );
  }

  /// Indication state shown when Flutter application is pre/during buildup.
  @visibleForTesting
  Widget onPreparingApp() {
    return Container(
      color: Colors.transparent,
    );
  }

  /// Trigger native side that the Flutter UI is ready for display. This is used to minimize any
  /// Jitter caused from widget buildup during initial flow.
  void readyForDisplay() {
    if (config.isMock) {
      return;
    }
    nssLogger.d('Ignition - invoke ready for display');
    try {
      channels.ignitionChannel.invokeMethod<void>(IgnitionChannelAction.ready_for_display.action);
    } on MissingPluginException catch (ex) {
      nssLogger.e('Missing channel connection: check mock state?');
    }
  }
}

/// Async worker used to fetch the JSON markup from the native controller.
class IgnitionWorker {
  final NssConfig config;
  final NssChannels channels;

  IgnitionWorker({
    @required this.config,
    @required this.channels,
  });

  @visibleForTesting
  Future<Spark> spark() async {
    var fetchData = config.isMock ? await _ignitionFromMock() : await _ignitionFromChannel();
    try {
      final Spark spark = Spark.fromJson(fetchData.cast<String, dynamic>());
      return spark;
    } on Exception catch (ex) {
      debugPrint('$ex.message');
      return null;
    }
  }

  /// Get the [Spark] markup from asset JSON file.
  Future<Map<dynamic, dynamic>> _ignitionFromMock() async {
    final String json = await AssetUtils.jsonFromAssets('assets/mock_login.json');
    return jsonDecode(json);
  }

  /// Get the [Spark] markup from native component using the ignition channel.
  Future<Map<dynamic, dynamic>> _ignitionFromChannel() async {
    return channels.ignitionChannel.invokeMethod<Map<dynamic, dynamic>>(IgnitionChannelAction.ignition.action);
  }
}
