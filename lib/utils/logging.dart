import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';

/// Logging is directed to the native controller using the static log method channel.
/// Default pattern uses the tag/message construct.
class Logger {
  final NssConfig config;
  final NssChannels channels;

  Logger(this.config, this.channels);

  d(String message, {String tag = 'NssEngine DEBUG'}) {
    if (config.isMock) {
      return;
    }
    try {
      channels.logChannel.invokeMethod<void>('debug', {'tag': tag, 'message': message});
    } on MissingPluginException catch (ex) {
      // No need to print the exception here.
    }
  }

  e(String message, {String tag = 'NssEngine ERROR'}) {
    if (config.isMock) {
      return;
    }
    try {
      channels.logChannel.invokeMethod<void>('error', {'tag': tag, 'message': message});
    } on MissingPluginException catch (ex) {
      // No need to print the exception here.
    }
  }
}

/// Global logger instance.
Logger engineLogger = NssIoc().use(Logger);
