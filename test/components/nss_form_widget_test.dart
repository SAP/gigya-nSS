import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/components/nss_form.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../nss_test_extensions.dart';

void main() {
  MockFormBloc bloc = MockFormBloc();
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
          bloc: bloc,
        ),
      );

      when(viewModel.streamEventSink).thenReturn(null);
      await tester.pumpWidget(form);

      final textFinder = find.textContains('Mock text');
      expect(textFinder, findsOneWidget);
    });
  });
}
