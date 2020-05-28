import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/models/routing.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/services/api_service.dart';
import 'package:gigya_native_screensets_engine/startup.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
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

mockLogging(config, channels) {
  var logger = MockLogger();
  NssIoc().register(Logger, (ioc) => logger);
  verifyZeroInteractions(logger);
}
//endregion

//region Mock classes

class MockConfig extends Mock implements NssConfig {}

class MockChannels extends Mock implements NssChannels {}

class MockMaterialWidgetFactory extends Mock implements MaterialWidgetFactory {}

class MockIgnitionWorker extends Mock implements StartupWorker {}

class MockApiChannel extends Mock implements MethodChannel {}

class MockScreenStateBloc extends Mock implements ScreenViewModel {}

class MockMarkup extends Mock implements Markup {}

class MockRouting extends Mock implements Routing {}

class MockScreen extends Mock implements Screen {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockScreenViewModel extends Mock implements ScreenViewModel {}

class MockApiService extends Mock implements ApiService {}

// ignore: must_be_immutable
class MockRouteSettings extends Mock implements RouteSettings {}

class MockBindingModel extends Mock implements BindingModel {}

class MockLogger extends Mock implements Logger {}

//endregion
