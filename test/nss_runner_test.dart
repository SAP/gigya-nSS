import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';

void main() {
  group("Rendering test", () {
    testWidgets("test rander elemnt", (WidgetTester tester) async {
      Map<String, Screen> mockData = {};
      mockData["test"] = Screen("test", NssAlignment.vertical, [NssWidget(NssWidgetType.label, "test label")]);

      await tester.pumpWidget(MaterialApp(home: NssLayoutBuilder("test").render(mockData)));

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('test label');

      expect(id1TextFinder, findsOneWidget);
    });

    testWidgets("render without screen", (WidgetTester tester) async {
      Map<String, Screen> mockData = {};
      mockData["test"] = Screen("test", NssAlignment.vertical, []);

      await tester.pumpWidget(MaterialApp(home: NssLayoutBuilder("").render(mockData)));

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('Initial route missmatch.'
          '\nMarkup does not contain requested route.');

      expect(id1TextFinder, findsOneWidget);
    });

    testWidgets("render without chidren", (WidgetTester tester) async {
      Map<String, Screen> mockData = {};
      mockData["test"] = Screen("test", NssAlignment.vertical, []);

      await tester.pumpWidget(MaterialApp(home: NssLayoutBuilder("test").render(mockData)));

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('Screen must contain children.'
          '\nMarkup tag \"screen\" must contain children.');

      expect(id1TextFinder, findsOneWidget);
    });

    testWidgets("test AppBar widget", (WidgetTester tester) async {
      Map<String, Screen> mockData = {};
      mockData['test'] = Screen('test', NssAlignment.vertical, [NssWidget(NssWidgetType.label, 'test label')]);
      mockData['test'].appBar = {'textKey': 'Test AppBar'};

      await tester.pumpWidget(MaterialApp(home: NssLayoutBuilder('test').render(mockData)));

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('Test AppBar');

      expect(id1TextFinder, findsOneWidget);
    });
  });
}