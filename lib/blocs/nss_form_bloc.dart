import 'package:flutter/widgets.dart';

class NssFormBloc with ChangeNotifier {
  final String _screenId;
  final GlobalKey<FormState> _formKey;

  NssFormBloc(this._formKey, this._screenId);

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
        return NssEmailInputValidator().validate(input)
            ? NssInputValidation.passed
            : NssInputValidation.failed;
      default:
        return NssInputValidation.na;
    }
  }
}

//region From Validations

/// Validation options.
enum NssInputValidation { passed, failed, na }

/// Base class for all custom input validators.
abstract class NssInputValidator {
  bool validate(text);
}

/// Lenient email validations (accepting "+" sign for instance) using regular expressions.
class NssEmailInputValidator extends NssInputValidator {
  @override
  bool validate(text) =>
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
}

//endregion
