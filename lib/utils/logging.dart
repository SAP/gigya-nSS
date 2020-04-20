import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';

/// Logging is directed to the native controller using the static log method channel.
/// Default pattern uses the tag/message construct.
class NssLogger {
  final NssChannels channels;
  final NssConfig config;

  NssLogger({
    @required this.channels,
    @required this.config,
  });

  d(String message, {String tag = 'NssEngine'}) {
    if (config.isMock) {
      return;
    }
    try {
      channels.logChannel.invokeMethod<void>('debug', {'tag': tag, 'message': message});
    } on MissingPluginException catch (ex) {
      // No need to print the exception here.
    }
  }

  e(String message, {String tag = 'none'}) {
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
NssLogger nssLogger = NssInjector().use(NssLogger);
