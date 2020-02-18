
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:test/test.dart';

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
}
