import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockRegistry extends Mock implements NssRegistryBloc {}

class MockChannels extends Mock implements NssChannelRegistry {}

class MockMainChannel extends Mock implements MethodChannel {}

void main() {
  group('Initialization tests', () {
    testWidgets('Testing engine initialization with "useMockData" true',
        (WidgetTester tester) async {
      await tester.pumpWidget(NssIgnitionWidget(
        layoutScreenSet: (Main main, String initialRoute) {
          return Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(main.screens['login'].id),
                  Text(main.screens['register'].id),
                ],
              ),
            ),
          );
        },
        useMockData: true,
      ));

      // Making sure the EngineInitializationWidget FutureBuilder has snapped.
      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('login');
      final id2TextFinder = find.text('register');

      expect(id1TextFinder, findsOneWidget);
      expect(id2TextFinder, findsOneWidget);
    });

    testWidgets('Testing engine initialization with "useMockData" false',
        (WidgetTester tester) async {
      final registry = MockRegistry();
      final channels = MockChannels();
      final mainChannel = MockMainChannel();

      var widget = MultiProvider(
        providers: [
          Provider<NssRegistryBloc>(
            create: (_) => registry,
          ),
        ],
        child: NssIgnitionWidget(
          layoutScreenSet: (Main main, String initialRoute) {
            return Container(
              child: Text(main.screens[initialRoute].id),
            );
          },
        ),
      );

      when(channels.mainChannel).thenReturn(mainChannel);
      when(mainChannel.invokeMethod(NssAction.ignition.action))
          .thenAnswer((_) => Future<Map<String, dynamic>>(() {
                final Map<String, dynamic> map = {};
                map['platformAware'] = false;
                map['markup'] = {
                  'screens': {
                    'login': {
                      'id': 'login',
                      'appbar': {'textKey': 'login'}
                    }
                  }
                };
                return map;
              }));
      when(registry.channels).thenReturn(channels);

      await tester.pumpWidget(widget);

      // Making sure the EngineInitializationWidget FutureBuilder has snapped.
      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final textFinder = find.text('login');

      expect(textFinder, findsOneWidget);
    });
  });
}
