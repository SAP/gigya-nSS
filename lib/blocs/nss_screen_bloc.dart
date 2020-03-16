import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/services/nss_api_service.dart';
import 'package:gigya_native_screensets_engine/services/nss_screen_service.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum NssScreenState { idle, progress, error }

enum ScreenAction { submit, api }

extension ScreenActionExt on ScreenAction {
  String get name => describeEnum(this);
}

class ScreenEvent {
  final ScreenAction action;
  Map<String, dynamic> data;

  ScreenEvent(this.action, this.data);
}

class NssScreenViewModel with ChangeNotifier {
  final ApiService apiService;
  final ScreenService screenService;
  Map<String, dynamic> dataMap;

  NssScreenViewModel(
    this.apiService,
    this.screenService,
  ) {
    // Register action steam.
    registerScreenActionsStream();
  }

  String id;

  // Screen state.
  NssScreenState _state = NssScreenState.idle;

  String _errorText;

  String get error => _errorText;

  final StreamController<ScreenEvent> screenEvents = StreamController<ScreenEvent>();
  final StreamController navigationStream = StreamController<String>();

  Sink get streamEventSink => screenEvents.sink;

  @override
  void dispose() {
    // Close screen event stream to avoid leaks.
    screenEvents.close();
    navigationStream.close();
    super.dispose();
  }

  /// Start listening for [ScreenEvent] action [ScreenAction] events.
  /// Events are propagated bottom up and are available for all child components.
  void registerScreenActionsStream() {
    screenEvents.stream.listen((ScreenEvent event) {
      nssLogger.d('ScreenEvent received with action: ${event.action.name} and data: ${event.data.toString()}');
      sendApi(event.action.name, event.data);
    });
  }

  void registerFlow(String withAction) async {
    dataMap = await screenService.requestFlow(withAction);
  }

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

  /// State management
  void setError(String error) {
    nssLogger.d('Screen with id: $id setError with $error');
    _state = NssScreenState.error;
    _errorText = error;
    notifyListeners();
  }

  /// Send requested API request given a String [method] and base [parameters] map.
  /// [parameter] map is not signed.
  void sendApi(String method, Map<String, dynamic> parameters) {
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
