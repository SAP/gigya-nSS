import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_state_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../test_extensions.dart';

class MockScreenStateBloc extends Mock implements NssScreenStateBloc { }

void main() {
  final screenStateBloc = MockScreenStateBloc();

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

    testWidgets('Testing error in screen', (WidgetTester tester) async {
      Provider.debugCheckInvalidValueType = null;
      
      var widget = MultiProvider(
        providers: [
          Provider<NssScreenStateBloc>(create: (_) => screenStateBloc),
        ],
        child: MaterialApp(home: Scaffold(body: NssFormErrorWidget())),
      );

      when(screenStateBloc.error).thenReturn('error is here');
      when(screenStateBloc.isError()).thenReturn(true);

      await tester.pumpWidget(widget);
      final textFinder = find.textContains('error is here');

      expect(textFinder, findsOneWidget);
    });
  });
}
