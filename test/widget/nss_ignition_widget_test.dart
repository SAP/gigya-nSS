import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/startup.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:mockito/mockito.dart';

import '../unit/nss_test_extensions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var config = MockConfig();
  var channels = MockChannels();
  mockLogging(config, channels);

  var worker = MockIgnitionWorker();
  var factory = MockMaterialWidgetFactory();
  NssIoc().register(MaterialWidgetFactory, (ioc) => factory);

  group('NssIgnitionWidget: ', () {
    testWidgets('prepareApp: mocked spark, isMock = true ', (WidgetTester tester) async {
      when(config.isMock).thenReturn(true);
      when(config.isPlatformAware).thenReturn(false);
      when(factory.buildApp()).thenReturn(Placeholder());

      var jsonAssetString = await AssetUtils.jsonFromAssets('assets/example.json');
      var mockedMarkup = Markup.fromJson(jsonDecode(jsonAssetString));

      var ignition = StartupWidget(worker: worker, config: config, channels: channels);

      var widget = ignition.prepareApp(mockedMarkup);
      expect(widget is Container, true);
      expect((widget as Container).child is Placeholder, true);
    });

    testWidgets('onPreparingApp: mocked spark, isMock = true ', (WidgetTester tester) async {
      when(config.isMock).thenReturn(true);

      var ignition = StartupWidget(
        worker: worker,
        config: config,
        channels: channels,
      );

      var widget = ignition.onPreparingApp();
      expect(widget is Container, true);
    });
  });
}
