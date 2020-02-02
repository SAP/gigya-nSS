import 'package:flutter/widgets.dart';

enum NssScreenState { idle, progress, error }

class NssScreenStateBloc with ChangeNotifier {
  NssScreenState _state = NssScreenState.idle;

  NssScreenStateBloc();

  String _errorText;

  String get error => _errorText;

  setError(String error) {
    _state = NssScreenState.error;
    _errorText = error;
    notifyListeners();
  }

  isIdle() => _state == NssScreenState.idle;

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
}
