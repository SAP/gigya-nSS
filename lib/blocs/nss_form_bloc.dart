import 'package:flutter/widgets.dart';

class NssFormBloc with ChangeNotifier {
  final GlobalKey<FormState> _formKey;

  NssFormBloc(this._formKey);

  GlobalKey<FormState> get key => _formKey;

  bool validateForm() => _formKey.currentState.validate();

  /// A map that will hold all relevant widget global keys.
  /// This way any widget in the form tree can access its adjacent widgets.
  /// Simple example is the submission action.
  final Map<String, GlobalKey> _keyMap = {};

  addChildWith(key, {String forId}) => _keyMap[forId] = key;

  GlobalKey keyFor(id) => _keyMap[id];

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

enum NssInputValidation { passed, failed, na }

abstract class NssInputValidator {
  bool validate(text);
}

/// Lenient email validations (accepting "+" sign for instance) using regular expressions.
class NssEmailInputValidator extends NssInputValidator {
  @override
  bool validate(text) =>
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
}
