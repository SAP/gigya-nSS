import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/initialization.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';

void main() {
  group('Initialization tests', () {
    testWidgets('Testing engine intialization widget using mock data from assets/mock1_json file',
        (WidgetTester tester) async {
      await tester.pumpWidget(EngineInitializationWidget(
        layoutScreenSet: (Main markup) {
          return Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(markup.screens['login'].id),
                  Text(markup.screens['register'].id),
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
  });
}
