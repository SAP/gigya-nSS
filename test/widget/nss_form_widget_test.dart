import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/components/nss_form.dart';
import 'package:provider/provider.dart';

import '../unit/nss_test_extensions.dart';

void main() {
  MockNssScreenViewModel viewModel = MockNssScreenViewModel();
  var mockScreenId = "mockId";

  var child = Container(
    child: Center(
      child: Text('Mock text', textDirection: TextDirection.ltr),
    ),
  );

  group('NssForm: ', () {

    testWidgets('Instantiation: ', (WidgetTester tester) async {
      // Instantiate.
      var form = ChangeNotifierProvider(
        create: (_) => viewModel,
        child: NssFormWidget(
          child: child,
          screenId: mockScreenId,
        ),
      );

      await tester.pumpWidget(form);

      final textFinder = find.textContains('Mock text');
      expect(textFinder, findsOneWidget);
    });
  });
}
