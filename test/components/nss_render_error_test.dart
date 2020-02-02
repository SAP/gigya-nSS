import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/components/nss_render_error.dart';
import '../test_extensions.dart';

void main() {
  group('Error widget factory tests', () {
    testWidgets('Testing route missmatch factory constructor', (WidgetTester tester) async {
      var widget = MaterialApp(home: NssErrorWidget.routeMissMatch());

      await tester.pumpWidget(widget);

      final textFinder = find.textContains('Initial route missmatch');

      expect(textFinder, findsOneWidget);
    });

    testWidgets('Testing missing children in screen factory constructor',
        (WidgetTester tester) async {
      var widget = MaterialApp(home: NssErrorWidget.screenWithNotChildren());

      await tester.pumpWidget(widget);
      final textFinder = find.textContains('Screen must contain children');

      expect(textFinder, findsOneWidget);
    });
  });
}
