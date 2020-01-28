import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/ui/errors.dart';

void main() {
  group('Error widget factory tests', () {
    testWidgets('Testing missing route factory constructor', (WidgetTester tester) async {
      var widget = MaterialApp(home: NssErrorWidget.missingRoute());

      await tester.pumpWidget(widget);

      final textFinder = find.text('Initial route missmatch.'
          '\nMarkup does not contain requested route.');

      expect(textFinder, findsOneWidget);
    });

    testWidgets('Testing missing children in screen factory constructor',
        (WidgetTester tester) async {
      var widget = MaterialApp(home: NssErrorWidget.screenWithNotChildren());

      await tester.pumpWidget(widget);

      final textFinder = find.text('Screen must contain children.'
          '\nMarkup tag \"screen\" must contain children.');

      expect(textFinder, findsOneWidget);
    });
  });
}
