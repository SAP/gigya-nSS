import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/utils/debug.dart';
import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/widgets/events.dart';
import 'package:gigya_native_screensets_engine/widgets/material/social.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';
import 'package:gigya_native_screensets_engine/services/api_service.dart';
import 'package:gigya_native_screensets_engine/services/screen_service.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum NssScreenState { idle, progress, error }

enum ScreenAction { submit, api, socialLogin }

extension ScreenActionExt on ScreenAction {
  String get name => describeEnum(this);
}

/// The view model class acts as the coordinator to the currently displayed screen.
/// It will handle the current screen visual state and its adjacent form and is responsible for service/repository
/// action triggering.
class ScreenViewModel with ChangeNotifier, DebugUtils, LocalizationMixin, EngineEvents {
  final ApiService apiService;
  final ScreenService screenService;

  ScreenViewModel(
    this.apiService,
    this.screenService,
  );

  /// Previous screen unique identifier.
  String pid = '';

  /// Screen unique identifier.
  String id;

  /// Create new globalKey which is important to trigger all form specific actions.
  /// Only one form can exist in one screen.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Stream controller responsible for triggering navigation events.
  /// The [NssScreenWidget] holds the correct [BuildContext] which can access the [Navigator]. Therefore it will
  /// be the only one listening to this stream.
  final StreamController navigationStream = StreamController<String>();

  @override
  void dispose() {
    // Close screen event stream to avoid leaks.
    navigationStream.close();
    super.dispose();
  }

  /// Attach screen action.
  /// Method will use the [ScreenService] to send the correct action to the native to initialize the correct
  /// native logic object.
  Future<Map<String, dynamic>> attachScreenAction(String action) async {
    try {
      var map = await screenService.initiateAction(action, id);
      engineLogger.d('Screen $id flow initialized with data map');
      return map;
    } on MissingPluginException {
      engineLogger.e('Missing channel connection: check mock state?');
      return {};
    }
  }

  /// Current screen [NssScreenState] state.
  /// Available states: idle, progress, error.
  NssScreenState _state = NssScreenState.idle;

  String _errorText;

  String get error => _errorText;

  isIdle() => _state == NssScreenState.idle;

  isProgress() => _state == NssScreenState.progress;

  isError() => _state == NssScreenState.error;

  /// Screen idle state.
  void setIdle() {
    engineLogger.d('Screen with id: $id setIdle');
    _state = NssScreenState.idle;
    _errorText = null;
    notifyListeners();
  }

  /// Screen in progress state. Will show common progress indicator ontop a semi transparent background.
  void setProgress() {
    engineLogger.d('Screen with id: $id setProgress');
    _state = NssScreenState.progress;
    _errorText = null;
    notifyListeners();
  }

  /// Screen in error mode. Will display a specific error under submission button.
  /// Other error display options will be added.
  void setError(String error) {
    engineLogger.d('Screen with id: $id setError with $error');
    _state = NssScreenState.error;

    // Check if error string exists in localization keys. If so use it.
    _errorText = localizedStringFor(error);
    notifyListeners();
  }

  /// Request form submission. Form will try to validate first. If validation succeeds than the submission action
  /// will be sent to the native container.
  void submitScreenForm(Map<String, dynamic> submission) async {
    var validated = formKey.currentState.validate();
    if (validated) {
      engineLogger.d('Form validations success - submission requested.');

      // Request form save state. This will update the binding map with the required data for submission.
      formKey.currentState.save();

      // Handle engine submit event.
      Map<String, dynamic> eventData = await beforeSubmit(id, submission);
      if (eventData.isNotEmpty) {
        if (eventData.containsKey('error')) {
          String error = eventData['error'];

          if (error.isEmpty) {
            engineLogger.d('Provided empty error message from event submission override');
          }
          setError(error);
          return;
        }

        // Overrite submission data if exists.
        Map<String, dynamic> submissionData = eventData['data'].cast<String, dynamic>();
        if (submissionData.isNotEmpty) submission = submissionData;
      }

      // Send API only if validated.
      sendApi(ScreenAction.submit.name, submission);
    }
  }

  /// Force form validation request.
  void requestScreenFormValidation() {
    formKey.currentState.validate();
  }

  /// Trigger natvie social login flow with selected [provider].
  void socialLogin(NssSocialProvider provider) {
    if (isMock) {
      debugPrint('Requeted social login with ${provider.name}');
      return;
    }
    sendApi(ScreenAction.socialLogin.name, {'provider': provider.name});
  }

  /// Label widget initiated link action.
  /// Validate option available are URL/route.
  void linkifyTap(String link) {
    engineLogger.d('link tap: $link');

    if (Linkify.isValidUrl(link)) {
      if (isMock) return;
      engineLogger.d('URL link validated : $link');
      screenService.linkToBrowser(link);
      return;
    }
    if (RouteEvaluator.validatedRoute(link)) {
      engineLogger.d('Route link validated : $link');
      navigationStream.sink.add('$link');
      return;
    }
  }

  /// Send requested API request given a String [method] and base [parameters] map.
  /// [parameter] map is not signed.
  void sendApi(String method, Map<String, dynamic> parameters) {
    if (isMock) return;
    setProgress();

    apiService.send(method, parameters).then(
      (result) {
        setIdle();
        engineLogger.d('Api request success: ${result.data.toString()}');

        //TODO: inject response data to screen routing data so the data will be passed to the next screen.

        // Trigger navigation.
        navigationStream.sink.add('$id/onSuccess');
      },
    ).catchError(
      (error) {
        final RoutingAllowed route = RouteEvaluator.allowedBy(error.errorCode);
        if (route != RoutingAllowed.none) {
          final routeNamed = describeEnum(route);
          navigationStream.sink.add('$id/$routeNamed');

          //TODO: inject response data to screen routing data so the data will be passed to the next screen.

        } else {
          // Error will be displayed when there is no available routing option.
          setError(error.errorMessage);
        }

        // Log the error.
        engineLogger.d('Api request error: ${error.errorMessage}');
      },
    );
  }
}
