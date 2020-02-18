import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/services/nss_api_service.dart';
import 'package:gigya_native_screensets_engine/models/api.dart';
import 'package:gigya_native_screensets_engine/utils/debug.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum NssScreenState { idle, progress, error }

class NssScreenViewModel with ChangeNotifier {
  final ApiService apiBloc = ApiService();

  NssScreenState _state = NssScreenState.idle;

  String _errorText;

  String get error => _errorText;

  final StreamController _screenEvents = StreamController<ScreenEvent>();

  Sink get streamEventSink => _screenEvents.sink;

  NssScreenViewModel() {
    _registerScreenActionsStream();
  }

  //region State management

  isIdle() => _state == NssScreenState.idle;

  isProgress() => _state == NssScreenState.progress;

  isError() => _state == NssScreenState.error;

  setIdle() {
    _state = NssScreenState.idle;
    _errorText = null;
    notifyListeners();
  }

  setProgress() {
    _state = NssScreenState.progress;
    _errorText = null;
    notifyListeners();
  }

  /// State management
  setError(String error) {
    _state = NssScreenState.error;
    _errorText = error;
    notifyListeners();
  }

  //endregion

  /// Start listening for [ScreenEvent] action [ScreenAction] events.
  /// Events are propagated bottom up and are available for all child components.
  _registerScreenActionsStream() {
    _screenEvents.stream.listen((event) {
      nssLogger.d('Event received with data: ${event.data.toString()}');

      sendApi(event.data['api'], event.data['params']);
    });
  }

  /// Send requested API request given a String [method] and base [parameters] map.
  /// [parameter] map is not signed.
  sendApi(String method, Map<String, dynamic> parameters) {
    // TODO: mock for testing.
    apiBloc.mock = ApiBaseResult(200, "test", "Email is empty", null, 42516);

    nssLogger.d('Screen state is: progress');

    setProgress();

    nssLogger.d('Start api request:' + method + '\n params: ' + parameters.toString());

    //TODO Using debug post delayed for demonstration.
    DebugUtils.postDelayed(3, () {
      apiBloc.send(method, parameters).then((result) {
        if (result.isSuccess()) {
          //TODO: What need to do with the data?
          setIdle();

          nssLogger.d('Api request success: ' + result.data.toString());
        } else {
          setError(result.errorMessage);

          nssLogger.d('Api request error: ' + result.errorMessage);
        }
      });
    });
  }

  @override
  void dispose() {
    // Close screen event stream to avoid leaks.
    _screenEvents.close();
    super.dispose();
  }
}

enum ScreenAction { submit, refresh }

class ScreenEvent {
  final ScreenAction action;
  final Map<String, dynamic> data;

  ScreenEvent(this.action, this.data);
}
