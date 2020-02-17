import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_api_service_bloc.dart';
import 'package:gigya_native_screensets_engine/models/api.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum NssScreenState { idle, progress, error }

class NssScreenStateBloc with ChangeNotifier {
  final ApiServiceBloc apiBloc = ApiServiceBloc();

  final StreamController _screenEvents = StreamController<ScreenEvent>();

  Sink get streamEventSink => _screenEvents.sink;

  /// State definition
  NssScreenState _state = NssScreenState.idle;

  String _errorText;

  String get error => _errorText;

  ///Constructor
  NssScreenStateBloc() {
    _registerForScreenActions();
  }

  /// Register for streamer
  _registerForScreenActions() {
    _screenEvents.stream.listen((event) {
      nssLogger.d('Event received with data: ${event.data.toString()}');

      sendApi(event.data['api'], event.data['params']);
    });
  }

  /// Send api.
  sendApi(String method, Map<String, dynamic> params) {

    // TODO: mock for testing.
    apiBloc.mock = ApiBaseResult(200, "test", "Email is empty", null, 42516);

    nssLogger.d('Screen state is: progress');

    setProgress();

    nssLogger.d('Start api request:' + method + '\n params: '+ params.toString());

    apiBloc.send(method, params).then((result) {
      if(result.isSuccess()) {
        //TODO: What need to do with the data?
        setIdle();

        nssLogger.d('Api request success: ' + result.data.toString());
      } else {
        setError(result.errorMessage);

        nssLogger.d('Api request error: ' + result.errorMessage);
      }
    });
  }

  /// State management
  setError(String error) {
    _state = NssScreenState.error;
    _errorText = error;
    notifyListeners();
  }

  isIdle() => _state == NssScreenState.idle;

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

  isProgress() => _state == NssScreenState.progress;


  /// Streamer dispose
  @override
  void dispose() {
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