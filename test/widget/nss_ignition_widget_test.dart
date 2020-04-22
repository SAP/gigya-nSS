import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/components/nss_app.dart';
import 'package:gigya_native_screensets_engine/models/spark.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:mockito/mockito.dart';

import '../unit/nss_test_extensions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var config = MockConfig();
  var channels = MockNssChannels();
  var router = MockRouter();
  var worker = MockIgnitionWorker();

  group('NssIgnitionWidget: ', () {
    testWidgets('prepareApp: mocked spark, isMock = true ', (WidgetTester tester) async {
      when(config.isMock).thenReturn(true);

      var jsonAssetString = await AssetUtils.jsonFromAssets('assets/mock_1.json');
      var mockedSpark = Spark.fromJson(jsonDecode(jsonAssetString));

      var ignition = NssIgnitionWidget(
        config: config,
        channels: channels,
        router: router,
        worker: worker,
      );

      var widget = ignition.prepareApp(mockedSpark);
      expect(widget is Container, true);
      expect((widget as Container).child is NssApp, true);
    });

    testWidgets('onPreparingApp: mocked spark, isMock = true ', (WidgetTester tester) async {
      when(config.isMock).thenReturn(true);

      var ignition = NssIgnitionWidget(
        config: config,
        channels: channels,
        router: router,
        worker: worker,
      );

      var widget = ignition.onPreparingApp();
      expect(widget is Container, true);
    });
  });
}
