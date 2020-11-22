import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/material/labels.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../unit/nss_test_extensions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Components instantiation - platfrom = false: ', () {
    // Mocking configuration for all group tests.
    var config = MockConfig();
    when(config.isMock).thenReturn(false);
    when(config.isPlatformAware).thenReturn(false);

    // Mocking binding provider.
    var binding = MockBindingModel();

    testWidgets('Label: ', (WidgetTester tester) async {
      var textKey = 'evaluation string';
      var data = NssWidgetData(
        type: NssWidgetType.label,
        textKey: textKey,
      );

      var widget = LabelWidget(
        data: data,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BindingModel>(
            create: (_) => binding,
            child: Column(
              children: <Widget>[
                widget,
              ],
            ),
          ),
        ),
      );

      final textFinder = find.textContains(textKey);
      expect(textFinder, findsOneWidget);
    });

    testWidgets('Input: ', (WidgetTester tester) async {});

    testWidgets('Submit: ', (WidgetTester tester) async {});

    testWidgets('Checkbox: ', (WidgetTester tester) async {});

    testWidgets('Radio: ', (WidgetTester tester) async {});

    testWidgets('Dropbox: ', (WidgetTester tester) async {});
  });
}
