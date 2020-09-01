import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/material/profile_photo.dart';

enum StartupAction { ignition, ready_for_display, load_schema }

extension StartupActionExt on StartupAction {
  String get action {
    return describeEnum(this);
  }
}

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class StartupWidget extends StatelessWidget {
  final StartupWorker worker;
  final NssConfig config;
  final NssChannels channels;

  const StartupWidget({Key key, this.worker, this.config, this.channels})
      : super(key: key);

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: worker.ignite(),
      builder: (context, AsyncSnapshot<Ignition> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          engineLogger.d('ignition - state - done');
          return prepareApp(snapshot.data);
        } else {
          return onPreparingApp();
        }
      },
    );
  }

  /// Commence Flutter application buildup according to provided [Spark] markup.
  @visibleForTesting
  Widget prepareApp(Ignition ignition) {
    config.markup = ignition.markup;
    config.isPlatformAware = ignition.markup.platformAware ?? false;
    if (ignition.schema != null) {
      config.schema = ignition.schema;
    }

    // Add default localization values that are needed (can be overriden by client).
    addDefultStringValues();

    // Notify native that we are ready to display. Pre-warm up done.
    issueNativeReadyForDisplay();

    WidgetFactory factory = NssIoc().use(config.isPlatformAware
        ? CupertinoWidgetFactory
        : MaterialWidgetFactory);
    return Container(color: Colors.white, child: factory.buildApp());
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
  void issueNativeReadyForDisplay() {
    if (config.isMock) {
      return;
    }
    engineLogger.d('Ignition - invoke ready for display');
    try {
      channels.ignitionChannel
          .invokeMethod<void>(StartupAction.ready_for_display.action);
    } on MissingPluginException catch (ex) {
      engineLogger.e('Missing channel connection: check mock state?');
    }
  }

  //TODO: Future versions - move to a specific logic class. Task may grow in time.
  void addDefultStringValues() {
    var localization = config.markup.localization;
    if (!localization[NssInputValidator.defaultLangKey]
        .containsKey(NssInputValidator.schemaErrorKeyRequired)) {
      config.markup.localization[NssInputValidator.defaultLangKey]
          [NssInputValidator.schemaErrorKeyRequired] = 'This field is required';
    }
    if (!localization[NssInputValidator.defaultLangKey]
        .containsKey(NssInputValidator.schemaErrorKeyRegEx)) {
      config.markup.localization[NssInputValidator.defaultLangKey]
              [NssInputValidator.schemaErrorKeyRegEx] =
          'Please enter a valid value';
    }
    if (!localization[NssInputValidator.defaultLangKey]
        .containsKey(NssInputValidator.schemaErrorKeyCheckbox)) {
      config.markup.localization[NssInputValidator.defaultLangKey]
              [NssInputValidator.schemaErrorKeyCheckbox] =
          'Checked field is mandatory';
    }
    if (!localization[NssInputValidator.defaultLangKey]
        .containsKey(ProfilePhotoWidget.profileErrorImageUpload)) {
      config.markup.localization[NssInputValidator.defaultLangKey]
              [ProfilePhotoWidget.profileErrorImageUpload] =
          'Failed to upload. Please try again';
    }
    if (!localization[NssInputValidator.defaultLangKey]
        .containsKey(ProfilePhotoWidget.profileErrorImageSize)) {
      config.markup.localization[NssInputValidator.defaultLangKey]
              [ProfilePhotoWidget.profileErrorImageSize] =
          'Image exceeded file-size limits';
    }
  }
}

class Ignition {
  final Markup markup;
  Map<dynamic, dynamic> schema;

  Ignition(this.markup, {this.schema});
}

/// Async worker used to fetch the JSON markup from the native controller.
class StartupWorker {
  final NssConfig config;
  final NssChannels channels;

  StartupWorker(this.config, this.channels);

  @visibleForTesting
  Future<Ignition> ignite() async {
    // Fetch and parse the markup.
    var fetchData =
        config.isMock ? await _markupFromMock() : await _markupFromChannel();
    final Markup markup = Markup.fromJson(fetchData.cast<String, dynamic>());
    Ignition ignition = Ignition(markup);

    // Fetch and parse the schema if needed.
    if (!config.isMock && markup.useSchemaValidations) {
      var rawSchema = await channels.ignitionChannel
          .invokeMethod<Map<dynamic, dynamic>>(
              StartupAction.load_schema.action);
      var newSchema = {
        'profile': rawSchema['profileSchema']['fields'],
        'data': rawSchema['dataSchema']['fields'],
        'subscriptions': rawSchema['subscriptionsSchema']['fields'],
        'preferences': rawSchema['preferencesSchema']['fields']
      };
      ignition.schema = newSchema;
    }
    return ignition;
  }

  /// Get the [Spark] markup from asset JSON file.
  Future<Map<dynamic, dynamic>> _markupFromMock() async {
    final String json = await AssetUtils.jsonFromAssets('assets/example.json');
    return jsonDecode(json);
  }

  /// Get the [Spark] markup from native component using the ignition channel.
  Future<Map<dynamic, dynamic>> _markupFromChannel() async {
    return channels.ignitionChannel
        .invokeMethod<Map<dynamic, dynamic>>(StartupAction.ignition.action);
  }
}
