import 'package:flutter/foundation.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:flutter/services.dart';

/// Logging is directed to the native controller using the static log method channel.
/// Default pattern uses the tag/message construct.
class NssLogger {
  final NssChannels channels;

  NssLogger({
    @required this.channels,
  });

  d(String message, {String tag = 'NssEngine'}) {
    try {
      channels.logChannel.invokeMethod<void>('debug', {'tag': tag, 'message': message});
    } on MissingPluginException catch (ex) {
      print(ex.message);
    }
  }

  e(String message, {String tag = 'none'}) {
    try {
      channels.logChannel.invokeMethod<void>('error', {'tag': tag, 'message': message});
    } on MissingPluginException catch (ex) {
      print(ex.message);
    }
  }
}

/// Global logger instance.
NssLogger nssLogger = NssInjector().use(NssLogger);
