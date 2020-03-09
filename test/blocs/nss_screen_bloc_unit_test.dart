import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_screen.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../nss_test_extensions.dart';

void main() {
  group('NssScreenViewModel widget:', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    Provider.debugCheckInvalidValueType = null;

    var config = MockConfig();
    var factory = MockWidgetFactory();
    var screenObj = MockScreen();

    NssContainer().startEngine();
    NssScreenViewModel screen;

    testWidgets('Successful request', (WidgetTester tester) async {
      screen = NssInjector().use(NssScreenViewModel);

      var ssObj = Screen('test', 'test', NssAlignment.horizontal, []);

      var screenWidget = NssScreenWidget(screen: ssObj, config: config, widgetFactory: factory);

      var testWidget = MultiProvider(
        providers: [
          Provider<NssScreenViewModel>.value(value: screen),
        ],
        child: screenWidget,
      );

      when(config.isMock).thenReturn(true);

      screen.id = "test";

      final List<MethodCall> log = <MethodCall>[];

      final Map<String, dynamic> params = {
        'statusCode': 200,
        'errorCode': 0,
        'callId': '1234',
        'errorMessage': 'ok'
      };

      screen.apiService.channels.apiChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return params;
      });

      screen.streamEventSink.add(
        ScreenEvent(
          ScreenAction.submit,
          {'api': 'test', 'params': params},
        ),
      );

      screen.navigationStream.stream.listen((e) {
        expect(e, 'test/success');
      });
    });

    testWidgets('Failed request', (WidgetTester tester) async {
      var config = NssConfig(isPlatformAware: false, isMock: false);

      NssInjector().register(NssConfig, (ioc) => config, singleton: true);
      screen = NssInjector().use(NssScreenViewModel);

      var factory = NssInjector().use(NssWidgetFactory);
      var ssObj = Screen('test', 'test', NssAlignment.horizontal,
          [NssWidgetData(type: NssWidgetType.label, textKey: 'test')]);
      var channels = NssInjector().use(NssChannels);

      var screenWidget = NssScreenWidget(
          screen: ssObj, config: config, widgetFactory: factory, channels: channels);

      var testWidget = MaterialApp(
          home: MultiProvider(
        providers: [
          Provider<NssScreenViewModel>.value(value: screen),
        ],
        child: screenWidget,
      ));

      screen.id = "test";

      final Map<String, dynamic> params = {
        'statusCode': 500,
        'errorCode': 0,
        'callId': '1234',
        'errorMessage': 'ok'
      };

      expect(screen.isIdle(), true);

      screen.apiService.channels.apiChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        return throw PlatformException(code: '500', message: 'error', details: '{}');
      });

      screen.streamEventSink.add(
        ScreenEvent(
          ScreenAction.submit,
          {'api': 'test', 'params': params},
        ),
      );

      await tester.pumpWidget(testWidget);

      await tester.pump(new Duration(seconds: 3));

      final textFinder = find.textContains('error');

      expect(textFinder, findsOneWidget);

      expect(screen.isError(), true);
    });
  });
}
