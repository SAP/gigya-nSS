import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../unit/nss_test_extensions.dart';

void main() {
  final screenStateBloc = MockScreenStateBloc();

  group('Error widget factory tests', () {
    testWidgets('Testing route missmatch factory constructor', (WidgetTester tester) async {
      var widget = MaterialApp(home: NssRenderingErrorWidget.routeMissMatch());

      await tester.pumpWidget(widget);

      final textFinder = find.textContains('Initial route missmatch');

      expect(textFinder, findsOneWidget);
    });

    testWidgets('Testing missing children in screen factory constructor', (WidgetTester tester) async {
      var widget = MaterialApp(home: NssRenderingErrorWidget.screenWithNotChildren());

      await tester.pumpWidget(widget);
      final textFinder = find.textContains('Screen must contain children');

      expect(textFinder, findsOneWidget);
    });

    testWidgets('Testing error in screen', (WidgetTester tester) async {
      Provider.debugCheckInvalidValueType = null;

      var widget = MultiProvider(
        providers: [
          Provider<NssScreenViewModel>(create: (_) => screenStateBloc),
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
