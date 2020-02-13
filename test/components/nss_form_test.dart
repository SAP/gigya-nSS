import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_state_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_inputs.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:provider/provider.dart';

void main() {
  var formKey = GlobalKey<FormState>();

  /// Unit group.
  group('NssFormBlock unit tests', () {
    test('Input map tests', () async {
      var bloc = NssFormBloc(formKey, 'screen-id', null);

      expect(bloc.inputMap, isNotNull);

      final key = GlobalKey(debugLabel: 'testKey');
      bloc.addInputWith(key, forId: 'email');

      expect(bloc.keyFor('email'), key);
    });
  });

  /// Widget group.
  group('NssForm widget tests', () {
    var inputEmail = NssTextInputWidget(
      data: NssWidgetData(
        id: 'email',
        type: NssWidgetType.email,
        textKey: 'email',
      ),
    );

    var inputPassword = NssTextInputWidget(
      data: NssWidgetData(
        id: 'password',
        type: NssWidgetType.password,
        textKey: 'password',
      ),
    );

    testWidgets('NssForm build test', (WidgetTester tester) async {
      var bloc = NssFormBloc(formKey, 'screen-id', null);

      var widget = Provider(
        create: (_) => bloc,
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              inputEmail,
              inputPassword,
            ],
          ),
        ),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(bloc.keyFor('email'), isNotNull);
      expect(bloc.keyFor('password'), isNotNull);
    });

    testWidgets('NssForm build, interact and submit test', (WidgetTester tester) async {
      var screenSteamMock = StreamController<ScreenEvent>();
      var bloc = NssFormBloc(formKey, 'screen-id', screenSteamMock.sink);

      var widget = Provider(
        create: (_) => bloc,
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              inputEmail,
              inputPassword,
            ],
          ),
        ),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final emailKey = bloc.keyFor('email');
      final passwordKey = bloc.keyFor('password');

      await tester.enterText(find.byKey(emailKey), 'test@email.com');
      await tester.enterText(find.byKey(passwordKey), 'iossucks');

      screenSteamMock.stream.listen((event) {
        print(event.action.toString());
        expect(event.data['api'], 'accounts.register');

        // Close the stream.
        screenSteamMock.close();
      });

      bloc.onFormSubmissionWith(action: 'accounts.register');
    });
  });
}
