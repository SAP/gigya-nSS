import 'package:flutter/foundation.dart';

class Logger {

  static debugLog(tag, message) {
    debugPrint('<<< $tag : $message >>>');
  }
}