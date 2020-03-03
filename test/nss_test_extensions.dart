import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
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

class MockConfig extends Mock implements NssConfig {}

class MockNssChannels extends Mock implements NssChannels {}

class MockWidgetFactory extends Mock implements NssWidgetFactory {}

class MockWorker extends Mock implements IgnitionWorker {}

class MockApiChannel extends Mock implements MethodChannel {}

class MockScreenStateBloc extends Mock implements NssScreenViewModel {}

class MockFormBloc extends Mock implements NssFormBloc {}

class MockMain extends Mock implements Main {}

class MockScreen extends Mock implements Screen {}

class MockMethodChannel extends Mock implements MethodChannel {}

// ignore: must_be_immutable
class MockRouteSettings extends Mock implements RouteSettings { }

//endregion
