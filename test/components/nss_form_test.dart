import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/components/nss_form.dart';

//TODO: Migrate to form block.

void main() {
  group('NssForm widget tests', () {
    testWidgets('Testing NssForm instantiation & registration', (WidgetTester tester) async {
      var widget = NssFormWidget(
          screenId: 'some-id',
          layoutForm: () {
            return Container(
              child: Column(
                children: <Widget>[

                ],
              ),
            );
          });

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
    });
  });
}
