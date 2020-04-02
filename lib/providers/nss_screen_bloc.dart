import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/services/nss_api_service.dart';
import 'package:gigya_native_screensets_engine/services/nss_screen_service.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum NssScreenState { idle, progress, error }

enum ScreenAction { submit, api }

extension ScreenActionExt on ScreenAction {
  String get name => describeEnum(this);
}

/// The view model class acts as the coordinator to the currently displayed screen.
/// It will handle the current screen visual state and its adjacent form and is responsible for service/repository
/// action triggering.
class NssScreenViewModel with ChangeNotifier {
  final ApiService apiService;
  final ScreenService screenService;

  NssScreenViewModel(
    this.apiService,
    this.screenService,
  );

  /// Screen unique identifier.
  String id;

  /// Create new globalKey which is important to trigger all form specific actions.
  /// Only one form can exist in one screen.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Trigger cross form validation.
  bool validateForm() => formKey.currentState.validate();

  /// Trigger cross form data save.
  void _saveForm() => formKey.currentState.save();

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
      var map = await screenService.requestFlow(action);
      nssLogger.d('Screen $id flow initialized with data map');
      return map;
    } on MissingPluginException {
      nssLogger.e('Missing channel connection: check mock state?');
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

  void setIdle() {
    nssLogger.d('Screen with id: $id setIdle');
    _state = NssScreenState.idle;
    _errorText = null;
    notifyListeners();
  }

  void setProgress() {
    nssLogger.d('Screen with id: $id setProgress');
    _state = NssScreenState.progress;
    _errorText = null;
    notifyListeners();
  }

  void setError(String error) {
    nssLogger.d('Screen with id: $id setError with $error');
    _state = NssScreenState.error;
    _errorText = error;
    notifyListeners();
  }

  /// Request form submission. Form will try to validate first. If validation succeeds than the submission action
  /// will be sent to the native container.
  void submitScreenForm(Map<String, dynamic> submission) {
    if (validateForm()) {
      nssLogger.d('Form validations passed');

      // Request form save state.
      _saveForm();

      sendApi(ScreenAction.submit.name, submission);
    }
  }

  /// Send requested API request given a String [method] and base [parameters] map.
  /// [parameter] map is not signed.
  void sendApi(String method, Map<String, dynamic> parameters) {
    setProgress();

    apiService.send(method, parameters).then(
      (result) {
        setIdle();
        nssLogger.d('Api request success: ${result.data.toString()}');

        // Trigger navigation.
        navigationStream.sink.add('$id/success');
      },
    ).catchError(
      (error) {
        setError(error.errorMessage);
        nssLogger.d('Api request error: ${error.errorMessage}');
      },
    );
  }
}
