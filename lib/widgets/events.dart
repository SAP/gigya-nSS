import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

/// Screen native events handler class used to interact with dynamic native code.
mixin EngineEvents {
  final MethodChannel eventChannel = NssIoc().use(NssChannels).eventsChannel;

  /// Trigger first screen load event.
  /// This event will only occur after the first screen state build.
  /// Event will include current screend [sid].
  void screenDidLoad(sid) {
    engineLogger.d('Screen did load for $sid');
    eventChannel.invokeMethod<void>('screenDidLoad', {'sid': sid});
  }

  /// Trigger route into screen event.
  /// This event will include the previous screen [pid] and its [routingData] if exists.
  Future<Map<String, dynamic>> routeFrom(sid, pid, Map<String, dynamic> routingData) async {
    engineLogger.d('Screen route from $pid with ${routingData.toString()}');
    var eventData = await eventChannel.invokeMethod<Map<dynamic, dynamic>>('routeFrom', {
      'sid': sid,
      'pid': pid,
      'data': routingData,
    }).timeout(Duration(seconds: 10), onTimeout: () {
      return {'data':{}}.cast<String, dynamic>();
    });
    return eventData.cast<String, dynamic>();
  }

  /// Trigger route out of screen event.
  /// This event will include the next screen [nid] and the current screen [routingData] if exists.
  Future<Map<String, dynamic>> routeTo(sid, nid, Map<String, dynamic> routingData) async {
    engineLogger.d('Screen route to $nid with ${routingData.toString()}');
    var eventData = await eventChannel.invokeMethod<Map<dynamic, dynamic>>('routeTo', {
      'sid': sid,
      'nid': nid,
      'data': routingData,
    }).timeout(Duration(seconds: 10), onTimeout: () {
      return {'data':{}}.cast<String, dynamic>();
    });
    return eventData.cast<String, dynamic>();
  }

  /// Trigger submission event.
  /// This event will include the current submission.
  Future<Map<String, dynamic>> beforeSubmit(sid, submission) async {
    engineLogger.d('Submission with submission data ${submission.toString()}');
    var eventData = await eventChannel.invokeMethod<Map<dynamic, dynamic>>(
        'submit', {'sid': sid, 'data': submission}).timeout(Duration(seconds: 10), onTimeout: () {
      return {'data':{}}.cast<String, dynamic>();
    });

    var submissionData = eventData['data'].cast<String, dynamic>();
    return submissionData;
  }

  /// Trigger input field change event giving its [binding] identifier and [from] and [to] values.
  Future<dynamic> fieldDidChange(binding, from, to) async {
    engineLogger.d('fieldDidChange with $binding and value from $from to $to');
    return eventChannel.invokeMethod('fieldDidChane', {'field': binding, 'from': from, 'to': to});
  }
}
