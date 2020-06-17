/// Base class for all custom input validators.
class NssInputValidator {
  bool enabled;
  String errorKey;
  String value;

  NssInputValidator.from(Map<String, dynamic> json)
      : enabled = json["enabled"],
        errorKey = json["errorKey"],
        value = json["value"];
}
