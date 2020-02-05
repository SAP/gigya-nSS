import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_form.dart';
import 'package:provider/provider.dart';
import '../test_extensions.dart';

//TODO: Migrate to form block.

class TextChildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('building child');
    return Container(
      child: Text(Provider
          .of<NssRegistryBloc>(context)
          .forms
          .formKeyFor('some-id')
          .toString()),
    );
  }
}

void main() {
  group('NssForm widget tests', () {
    testWidgets('Testing NssForm instantiation & registration', (WidgetTester tester) async {
      var widget = MultiProvider(
        providers: [
          Provider<NssRegistryBloc>(
            create: (_) => NssRegistryBloc(),
          ),
        ],
        child: NssFormWidget(
            screenId: 'some-id',
            layoutForm: () {
              return Container(
                child: Column(
                  children: <Widget>[
                    TextChildWidget(),
                  ],
                ),
              );
            }),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final textFinder = find.textContains('some-id');

      expect(textFinder, findsOneWidget);
    });
  });
}
