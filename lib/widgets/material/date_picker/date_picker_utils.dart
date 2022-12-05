import 'package:gigya_native_screensets_engine/utils/logging.dart';

mixin DatePickerUtilsMixin {
  /// Get first date descriptor of the picker object given start year value.
  DateTime getFirstDateFrom(int? startYear) {
    return new DateTime(
        startYear == null ? DateTime.now().year : startYear, 1, 1);
  }

  /// Get last date descriptor of the picker object given end year value.
  DateTime getLastDateFrom(int? endYear) {
    return new DateTime(endYear == null ? DateTime.now().year : endYear, 13, 0);
  }

  /// Get the output date in iso8601.
  /// This is relevant for a single bind value.
  String toIso8601Value(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Convert ISO 8601 formatted [value] to [DateTime] object.
  DateTime fromIso8601Value(String value) {
    if (value.isEmpty) {
      engineLogger!
          .e('DatePicker (_fromIso8601Value) - Value empty. fallback to now');
      return DateTime.now();
    }
    return DateTime.parse(value);
  }

  /// Parse the display value of the picker.
  String parseDateValue(DateTime? time) {
    if (time == null) return '';
    return "${time.toLocal()}".split(' ')[0];
  }
}
