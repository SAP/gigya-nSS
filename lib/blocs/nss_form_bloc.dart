import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

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

  void _saveForm() => formKey.currentState.save();

  /// Instantiate and validate a specific input value.
  /// Validation [forType] is set using the widget's type parameter.
  NssInputValidation validate(String input, {String forType}) {
    switch (forType) {
      case 'email':
        return NssEmailInputValidator().validate(input) ? NssInputValidation.passed : NssInputValidation.failed;
      default:
        return NssInputValidation.na;
    }
  }

  /// Form submission trigger.
  /// This is available to every submission widget.
  /// Will first trigger form validation and move on to collect all relevant data for the screen
  /// action provided in the [action] parameter.
  onFormSubmissionWith({String action}) {
    nssLogger.d('Submission request with action $action');
    if (validateForm()) {
      nssLogger.d('Form validations passed');

      // Request form save state.
      _saveForm();

      // Gather inputs.
      Map<String, String> submission = model._inputData;

      screenSink?.add(
        ScreenEvent(
          ScreenAction.submit,
          {'api': action, 'params': submission},
        ),
      );
    }
  }
}

class NssFormModel {
  final _inputData = Map<String, String>();

  addInput(key, String input) {
    _inputData[key] = input;
  }

  String getInputFor(key) {
    return _inputData[key];
  }
}

//region From Validations

//TODO: Validations will move to independent file later on.

/// Validation options.
enum NssInputValidation { passed, failed, na }

/// Base class for all custom input validators.
abstract class NssInputValidator {
  bool validate(text);
}

/// Lenient email validations (accepting "+" sign for instance) using regular expressions.
class NssEmailInputValidator extends NssInputValidator {
  @override
  bool validate(text) => RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
}

//endregion
