import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:mockito/mockito.dart';

//region Test extensions

extension CommonFindersExtension on CommonFinders {
  /// Custom [Finder] for partial text matching.
  Finder textContains(String containsString) => find.byWidgetPredicate((widget) {
        if (widget is Text) {
          final Text textWidget = widget;
          if (textWidget.data != null) return textWidget.data.contains(containsString);
          return textWidget.textSpan.toPlainText().contains(containsString);
        }
        return false;
      });
}

//endregion

//region Mock classes
class MockWorker extends Mock implements IgnitionWorker {}

//endregion
