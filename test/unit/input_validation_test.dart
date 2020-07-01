import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:test/test.dart';

void main() {
  group('Validations: ', () {
    /// REGEX:
    /// Contains only alpha numerical characters.
    test(
      'regex test #1 - various',
      () async {
        var validatorMap = {
          "enabled": true,
          "format": "^[a-zA-Z0-9]+\$",
          "errorKey": "Invalid format",
        };

        NssInputValidator regexValidator = NssInputValidator.from(validatorMap);
        final RegExp regExp = RegExp(regexValidator.format);

        // Valid formats.
        expect(regExp.hasMatch("abc1"), true);
        expect(regExp.hasMatch("aBc45DSDsdf"), true);

        // Invalid formats.
        expect(regExp.hasMatch("12_34"), false);
        expect(regExp.hasMatch("%sdslk&"), false);
      },
    );

    test(
      /// (?=.*[A-Z])              // Should contain at least one upper case.
      /// (?=.*[a-z])              // Should contain at least one lower case.
      /// (?=.*?[0-9])             // Should contain at least one digit.
      /// (?=.*?[!@%#\$&*~])       // Should contain at least one Special character.
      /// .{8,}                    // Should be at least 8 digits long.
      'regex test #2 - password',
      () async {
        var validatorMap = {
          "enabled": true,
          "value": "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@%#\$&*~]).{8,}",
          "errorKey": "Invalid format",
        };

        NssInputValidator regexValidator = NssInputValidator.from(validatorMap);
        final RegExp regExp = RegExp(regexValidator.format);

        // Valid formats.
        expect(regExp.hasMatch("Aa123#dgdg"), true);
        expect(regExp.hasMatch("OneDigit1sEnoug%2"), true);

        // Invalid formats.
        expect(regExp.hasMatch("12_34"), false);
        expect(regExp.hasMatch("%sdslk&"), false);
      },
    );

    test(
      'regex test #3 - email',
      () async {
        var validatorMap = {
          "enabled": true,
          "value": "^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
          "errorKey": "Invalid format",
        };

        NssInputValidator regexValidator = NssInputValidator.from(validatorMap);
        final RegExp regExp = RegExp(regexValidator.format);

        // Valid formats.
        expect(regExp.hasMatch("abx@cc.com"), true);
        expect(regExp.hasMatch("someemail@gmail.com"), true);

        // Invalid formats.
        expect(regExp.hasMatch("aa.com"), false);
        expect(regExp.hasMatch("aa@bb"), false);
      },
    );
  });
}
