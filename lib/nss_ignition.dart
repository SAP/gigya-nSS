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
import 'package:gigya_native_screensets_engine/utils/extensions.dart';

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

  @visibleForTesting
  Widget prepareApp(Spark spark) {
    config.main = spark.markup;
    config.isPlatformAware = spark.platformAware ?? false;
    // Check spark object for initialRoute. If exists, it should overwrite the initial route
    // set in the markup object which is used to generate the dynamic routes.
    if (spark.initialRoute.isAvailable()) {
      config.main.initialRoute = spark.initialRoute;
    }
    // Notify native that we are ready to display. Pre-warm up done.
    readyForDisplay();
    return Container(
      color: Colors.white,
      child: NssApp(config: config, router: router),
    );
  }

  @visibleForTesting
  Widget onPreparingApp() {
    return Container(
      color: Colors.transparent,
    );
  }

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

/// Top level function for the spark computation.
/// Compute can only take top-level functions in order to correctly open the isolate.
Spark ignite(String json) {
  return Spark.fromJson(jsonDecode(json));
}

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
    return compute(ignite, fetchData);
  }

  Future<String> _ignitionFromMock() async {
    return AssetUtils.jsonFromAssets('assets/mock_1.json');
  }

  Future<String> _ignitionFromChannel() async {
    return channels.ignitionChannel.invokeMethod<String>(IgnitionChannelAction.ignition.action);
  }
}
