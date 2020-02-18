import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';

import './nss_test_extensions.dart';

void main() {
  group('NssLayoutBuilder widget tests', () {
    testWidgets('NssLayoutBuilder simple element', (WidgetTester tester) async {
      Map<String, Screen> mockData = {
        'test': Screen('test', NssAlignment.vertical, [
          NssWidgetData(textKey: 'test label', type: NssWidgetType.label),
        ])
      };

      await tester.pumpWidget(
        MaterialApp(home: NssScreenBuilder('test').build(mockData)),
      );

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final textFinder = find.text('test label');

      expect(textFinder, findsOneWidget);
    });

    testWidgets('NssLayoutBuilder without screen', (WidgetTester tester) async {
      Map<String, Screen> mockData = {
        'test': Screen('test', NssAlignment.vertical, []),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: NssScreenBuilder('').build(mockData),
        ),
      );

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final textFinder = find.textContains('Initial route missmatch');

      expect(textFinder, findsOneWidget);
    });

    testWidgets('NssLayoutBuilder screen without children', (WidgetTester tester) async {
      Map<String, Screen> mockData = {
        'test': Screen('test', NssAlignment.vertical, []),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: NssScreenBuilder('test').build(mockData),
        ),
      );

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final textFinder = find.textContains('Screen must contain children');

      expect(textFinder, findsOneWidget);
    });

    testWidgets('NssLayoutBuilder with appbar', (WidgetTester tester) async {
      var mockData = {
        'test': Screen('test', NssAlignment.vertical, [NssWidgetData(textKey: 'test label', type: NssWidgetType.label),],
            appBar: {'textKey': 'Test AppBar'}),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: NssScreenBuilder('test').build(mockData),
        ),
      );

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final textFinder = find.text('Test AppBar');

      expect(textFinder, findsOneWidget);
    });
  });
}
