import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

class NssFormBloc {
  final String _screenId;

  /// Reference saved to trigger form validation.
  final GlobalKey<FormState> _formKey;

  /// Stream sink used to communicate (one way) with the screen bloc. Can be null.
  final Sink<ScreenEvent> _screenSink;

  NssFormBloc(this._formKey, this._screenId, this._screenSink);

  String get screenId => _screenId;

  /// Trigger cross form validation.
  bool validateForm() => _formKey.currentState.validate();

  /// A map that will hold all relevant widget global keys.
  /// This way any widget in the form tree can access its adjacent widgets.
  /// Simple example is the submission action.
  final Map<String, GlobalKey> _inputKeyMap = {};

  Map<String, GlobalKey> get inputMap => _inputKeyMap;

  GlobalKey keyFor(id) => _inputKeyMap[id];

  /// Add id/globalKey pair of the form's child widget.
  /// This is used to keep track of the current state of the child widget and allow global
  /// access for business logic.
  addInputWith(key, {String forId}) => _inputKeyMap[forId] = key;

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

      Map<String, String> submission = {};

      // Gather inputs.
      if (_inputKeyMap.isNotEmpty) {
        _populateInputSubmissions(submission);
      }
      //TODO: Gather additional input from future widgets here.

      _screenSink?.add(
        ScreenEvent(
          ScreenAction.submit,
          {'api': action, 'params': submission},
        ),
      );
    }
  }

  /// Populate [submission] map with all relevant text inputs.
  _populateInputSubmissions(Map submission) {
    _inputKeyMap.forEach(
      (id, key) {
        // Just in case.
        if (key.currentWidget is TextFormField) {
          submission[id] = (key.currentWidget as TextFormField).controller?.text?.trim();
        }
      },
    );
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
