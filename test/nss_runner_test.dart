import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:gigya_native_screensets_engine/nss_runner.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockRegistry extends Mock implements NssRegistryBloc {}

class MockForms extends Mock implements NssFormRegistry {}

void main() {
  group('NssLayoutBuilder: ', () {
    final registry = MockRegistry();
    final forms = MockForms();

    when(registry.forms).thenReturn(forms);
    when(forms.formKeyFor('test')).thenReturn(GlobalKey<FormState>());

    Map<String, Screen> mockData = {};

    testWidgets('Rendering element', (WidgetTester tester) async {
      mockData.clear();

      mockData['test'] =
          Screen('test', NssAlignment.vertical, [NssWidgetData(NssWidgetType.label, 'test label')]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<NssRegistryBloc>(
              create: (_) => registry,
            ),
          ],
          child: MaterialApp(
            home: NssLayoutBuilder('test').render(mockData),
          ),
        ),
      );

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('test label');

      expect(id1TextFinder, findsOneWidget);
    });

    testWidgets('Missing screen', (WidgetTester tester) async {
      mockData.clear();

      mockData['test'] = Screen('test', NssAlignment.vertical, []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<NssRegistryBloc>(
              create: (_) => registry,
            ),
          ],
          child: MaterialApp(
            home: NssLayoutBuilder('').render(mockData),
          ),
        ),
      );

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('Initial route missmatch.'
          '\nMarkup does not contain requested route.');

      expect(id1TextFinder, findsOneWidget);
    });

    testWidgets('Missing children', (WidgetTester tester) async {
      mockData.clear();

      mockData['test'] = Screen('test', NssAlignment.vertical, []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<NssRegistryBloc>(
              create: (_) => registry,
            ),
          ],
          child: MaterialApp(
            home: NssLayoutBuilder('test').render(mockData),
          ),
        ),
      );

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('Screen must contain children.'
          '\nMarkup tag \"screen\" must contain children.');

      expect(id1TextFinder, findsOneWidget);
    });

    testWidgets('With appBar', (WidgetTester tester) async {
      mockData.clear();

      mockData['test'] =
          Screen('test', NssAlignment.vertical, [NssWidgetData(NssWidgetType.label, 'test label')]);
      mockData['test'].appBar = {'textKey': 'Test AppBar'};

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<NssRegistryBloc>(
              create: (_) => registry,
            ),
          ],
          child: MaterialApp(
            home: NssLayoutBuilder('test').render(mockData),
          ),
        ),
      );

      await tester.pump(Duration(seconds: 2), EnginePhase.build);

      final id1TextFinder = find.text('Test AppBar');

      expect(id1TextFinder, findsOneWidget);
    });
  });
}
