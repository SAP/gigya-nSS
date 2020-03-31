import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';

class NssFormBloc {
  final NssFormModel model;

  NssFormBloc({
    @required this.model,
  });

  String screenId;

  /// Reference saved to trigger form validation.
  GlobalKey<FormState> formKey;

  /// Stream sink used to communicate (one way) with the screen bloc. Can be null.
  Sink<ScreenEvent> screenSink;

  /// Trigger cross form validation.
  bool validateForm() => formKey.currentState.validate();

  /// Trigger cross form data save.
  void _saveForm() => formKey.currentState.save();

  /// Form submission trigger.
  /// This is available to every submission widget.
  /// Will first trigger form validation and move on to collect all relevant data for the screen
  /// action provided in the [action] parameter.
  void onFormSubmission() {
    nssLogger.d('Submission request for screen: $screenId');
    if (validateForm()) {
      nssLogger.d('Form validations passed');

      // Request form save state.
      _saveForm();

      // Gather inputs.
      Map<String, String> submission = model._inputData;

      screenSink?.add(
        ScreenEvent(
          ScreenAction.submit,
          {'params': submission},
        ),
      );
    }
  }
}

/// Form submission data model.
/// Data will be accumulated once form [onSaved] method will be called.
class NssFormModel {
  final _inputData = Map<String, String>();

  addInput(key, String input) {
    _inputData[key] = input;
  }

  String getInputFor(key) {
    return _inputData[key];
  }
}
