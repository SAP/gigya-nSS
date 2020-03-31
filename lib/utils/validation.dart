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

/// Instantiate and validate a specific input value.
/// Validation [forType] is set using the widget's type parameter.
class NssValidations {
  static NssInputValidation validate(String input, {String forType}) {
    switch (forType) {
      case 'email':
        return NssEmailInputValidator().validate(input) ? NssInputValidation.passed : NssInputValidation.failed;
      default:
        return NssInputValidation.na;
    }
  }
}
