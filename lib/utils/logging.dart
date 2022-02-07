import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';

/// Logging is directed to the native controller using the static log method channel.
/// Default pattern uses the tag/message construct.
class Logger {
  final NssConfig? config;
  final NssChannels? channels;

  // General tag for debug logging.
  static String dTag = "NSS_DEBUG";

  Logger(this.config, this.channels);

  /// Trigger a native debug log.
  d(String message, {String tag = 'NssEngine DEBUG'}) {
    if (config!.isMock!) {
      return;
    }
    try {
      channels!.logChannel
          .invokeMethod<void>('debug', {'tag': tag, 'message': message});
    } on MissingPluginException catch (ex) {
      // No need to print the exception here.
    }
  }

  /// Trigger a native error log.
  e(String message, {String tag = 'NssEngine ERROR'}) {
    debugPrint('Engine error for logger: $message');
    if (config!.isMock!) {
      return;
    }
    try {
      channels!.logChannel
          .invokeMethod<void>('error', {'tag': tag, 'message': message});
    } on MissingPluginException catch (ex) {
      // No need to print the exception here.
    }
  }
}

/// Global logger instance.
Logger? engineLogger = NssIoc().use(Logger);
