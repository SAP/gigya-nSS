import 'package:flutter/widgets.dart';

mixin NssActionsMixin {
  /// Call to dismiss keyboard from current focusable input component.
  dismissKeyboardWith(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
