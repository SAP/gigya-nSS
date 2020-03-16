import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/services/nss_api_service.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum NssScreenState { idle, progress, error }

enum ScreenAction { submit, api }

extension ScreenActionExt on ScreenAction {
  String get name => describeEnum(this);
}

class ScreenEvent {
  final ScreenAction action;
  final Map<String, dynamic> data;

  ScreenEvent(this.action, this.data);
}

class NssScreenViewModel with ChangeNotifier {
  final ApiService apiService;

  NssScreenViewModel(this.apiService) {
    // Register action steam.
    _registerScreenActionsStream();
  }

  String id;

  // Screen state.
  NssScreenState _state = NssScreenState.idle;

  String _errorText;

  String get error => _errorText;

  final StreamController<ScreenEvent> _screenEvents = StreamController<ScreenEvent>();
  final StreamController navigationStream = StreamController<String>();

  Sink get streamEventSink => _screenEvents.sink;

  @override
  void dispose() {
    // Close screen event stream to avoid leaks.
    _screenEvents.close();
    navigationStream.close();
    super.dispose();
  }

  /// Start listening for [ScreenEvent] action [ScreenAction] events.
  /// Events are propagated bottom up and are available for all child components.
  _registerScreenActionsStream() {
    _screenEvents.stream.listen((ScreenEvent event) {
      nssLogger.d('ScreenEvent received with action: ${event.action.name} and data: ${event.data.toString()}');
      sendApi(event.action.name, event.data);
    });
  }

  isIdle() => _state == NssScreenState.idle;

  isProgress() => _state == NssScreenState.progress;

  isError() => _state == NssScreenState.error;

  setIdle() {
    nssLogger.d('Screen with id: $id setIdle');
    _state = NssScreenState.idle;
    _errorText = null;
    notifyListeners();
  }

  setProgress() {
    nssLogger.d('Screen with id: $id setProgress');
    _state = NssScreenState.progress;
    _errorText = null;
    notifyListeners();
  }

  /// State management
  setError(String error) {
    nssLogger.d('Screen with id: $id setError with $error');
    _state = NssScreenState.error;
    _errorText = error;
    notifyListeners();
  }

  /// Send requested API request given a String [method] and base [parameters] map.
  /// [parameter] map is not signed.
  sendApi(String method, Map<String, dynamic> parameters) {
    setProgress();

    apiService.send(method, parameters).then((result) {
      setIdle();
      nssLogger.d('Api request success: ${result.data.toString()}');

      navigationStream.sink.add('$id/success');
    }).catchError((error) {
      setError(error.errorMessage);
      nssLogger.d('Api request error: ${error.errorMessage}');
    });
  }
}
