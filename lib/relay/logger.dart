import 'package:flutter/foundation.dart';

class Logger {
  static d(String message) {
    var buffer = new StringBuffer();

    for (var i = 0; i < message.length + 6; i++) {
      buffer.write("-");
    }

    buffer.write("\n");
    buffer.write("-- ${message.runtimeType}\n");
    buffer.write("-- $message\n --");

    for (var i = 0; i < message.length + 6; i++) {
      buffer.write("-");
    }

    debugPrint(buffer.toString());
  }
}
