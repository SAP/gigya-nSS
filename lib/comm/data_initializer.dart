import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gigya_native_screensets_engine/comm/channels.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/utils/error.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

class DataInitializer with Logging {
  final NssConfig config = NssIoc().use(NssConfig);

  Future<void> getRequiredMockDataForEngineInitialization() async {
    // DEBUG LOG.
    log('requesting MOCK markup on ignition channel');

    // Fetch markup.
    var markupData = await _getMockMarkup();
    final Markup markup = Markup.fromJson(markupData.cast<String, dynamic>());

    // Fetch styles.
    var stylesDataMap = await _getMockStyles();
    config.styleLibrary = stylesDataMap;
    _populateStyleLibraryDefaults();

    // Bind markup to config & set awareness mode.
    config.markup = markup;
    config.markupBackup = Markup.fromJson(markupData.cast<String, dynamic>());
    config.platformAwareMode = markup.platformAwareMode ?? 'material';

    //Add default localization values that are needed (can be overridden by client).
    ErrorUtils().addDefaultStringValues(config.markup!.localization!);
  }

  Future<void> getRequiredDataForEngineInitialization() async {
    // DEBUG LOG.
    log('requesting markup on ignition channel');

    // Fetch markup.
    var markupData = await _getMarkup(config.version);
    final Markup markup = Markup.fromJson(markupData.cast<String, dynamic>());

    // Fetch styles.
    var stylesDataMap = await _getStyles(config.version);
    if (stylesDataMap.isEmpty) {
      stylesDataMap = await _getMockStyles();
    }
    config.styleLibrary = stylesDataMap;
    _populateStyleLibraryDefaults();

    // Bind markup to config & set awareness mode.
    config.markup = markup;
    config.markupBackup = Markup.fromJson(markupData.cast<String, dynamic>());
    config.platformAwareMode = markup.platformAwareMode ?? 'material';

    // Fetch schema and set in config if required.
    if (schemaRequired(markup, config)) {
      // DEBUG LOG.
      log('requesting schema on ignition channel (schemaValidations)');

      var rawSchema = await _getSchema();
      var newSchema = {
        'profile': rawSchema['profileSchema']['fields'],
        'data': rawSchema['dataSchema']['fields'],
        'subscriptions': rawSchema['subscriptionsSchema']['fields'],
        'preferences': rawSchema['preferencesSchema']['fields']
      };
      config.schema = newSchema;
    }

    //Add default localization values that are needed (can be overridden by client).
    ErrorUtils().addDefaultStringValues(config.markup!.localization!);
  }

  /// Is schema data fetch required.
  /// When using schema validation & not in mock mode.
  bool schemaRequired(Markup markup, NssConfig config) {
    return markup.useSchemaValidations! && !config.isMock!;
  }

  /// Fetch markup from native/web communication "ignition" channel.
  Future<Map<dynamic, dynamic>> _getMarkup(version) async {
    return NssIoc()
        .use(NssChannels)
        .ignitionChannel
        .invokeMethod<Map<dynamic, dynamic>>('ignition', {'version': version});
  }

  Future<Map<dynamic, dynamic>> _getStyles(version) async {
    return NssIoc()
        .use(NssChannels)
        .ignitionChannel
        .invokeMethod<Map<dynamic, dynamic>>(
            'ignition_styles', {'version': version});
  }

  /// Fetch markup from example JSON asset.
  /// This is used for development & testing.
  Future<Map<dynamic, dynamic>> _getMockMarkup() async {
    final String json =
        await rootBundle.loadString('assets/example_tests.json');
    return jsonDecode(json);
  }

  /// Fetch styles from example JSON asset.
  /// This is used for development & testing.
  Future<Map<dynamic, dynamic>> _getMockStyles() async {
    final String json = await rootBundle.loadString('assets/styles.json');
    return jsonDecode(json);
  }

  /// Fetch raw schema from native/web communication "ignition" channel.
  Future<Map<dynamic, dynamic>> _getSchema() async {
    return NssIoc()
        .use(NssChannels)
        .ignitionChannel
        .invokeMethod<Map<dynamic, dynamic>>('load_schema');
  }

  /// Populate default style library components.
  _populateStyleLibraryDefaults() {
    config.styleLibrary.forEach((widgetIdentifier, widgetStyleMap) {
      if (widgetStyleMap != null) {
        (widgetStyleMap as Map).forEach((key, value) {
          Map data = value["data"];
          final bool isDefault = data["default"];
          if (isDefault) {
            config.styleLibraryDefaults[widgetIdentifier] = value;
          }
        });
      }
    });
  }
}
