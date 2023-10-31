import 'package:flutter/foundation.dart';
import 'package:gigya_native_screensets_engine/comm/channels.dart';
import 'package:gigya_native_screensets_engine/comm/mobile_channel.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum EventIdentifier { routeFrom, routeTo, submit, fieldDidChange }

extension EventIdentifierExt on EventIdentifier {
  String get name {
    return describeEnum(this);
  }
}

/// Screen native events handler class used to interact with dynamic native code.
mixin EngineEvents {
  final NssChannel? eventChannel = NssIoc().use(NssChannels).eventsChannel;
  final bool? isMock = NssIoc().use(NssConfig).isMock;

  // Setting the timeout for all event channel invocations.
  // Debug timeout is submitlonger for testing purposes.
  final int eventTimeoutDuration = !kReleaseMode ? 60 : 10;

  /// Trigger first screen load event.
  /// This event will only occur after the first screen state build.
  /// Event will include current screend [sid].
  void screenDidLoad(sid) {
    if (isMock!) {
      return;
    }
    engineLogger!.d('Screen did load for $sid');
    eventChannel!.invokeMethod<void>('screenDidLoad', {'sid': sid});
  }

  /// Trigger route into screen event.
  /// This event will include the previous screen [pid] and its [routingData] if exists.
  Future<Map<String, dynamic>> routeFrom(sid, pid, Map<String, dynamic>? routingData) async {
    if (isMock!) {
      return {};
    }
    engineLogger!.d('Screen route from $pid with ${routingData.toString()}');
    var eventData =
        await eventChannel!.invokeMethod<Map<dynamic, dynamic>>(EventIdentifier.routeFrom.name, {
      'sid': sid,
      'pid': pid,
      'data': routingData,
    }).timeout(Duration(seconds: eventTimeoutDuration), onTimeout: () {
      return {'data': {}}.cast<String, dynamic>();
    });
    return eventData.cast<String, dynamic>();
  }

  /// Trigger route out of screen event.
  /// This event will include the next screen [nid] and the current screen [routingData] if exists.
  Future<Map<String, dynamic>> routeTo(sid, nid, Map<String, dynamic> routingData) async {
    if (isMock!) {
      return {};
    }
    engineLogger!.d('Screen route to $nid with ${routingData.toString()}');
    var eventData =
        await eventChannel!.invokeMethod<Map<dynamic, dynamic>>(EventIdentifier.routeTo.name, {
      'sid': sid,
      'nid': nid,
      'data': routingData,
    }).timeout(Duration(seconds: eventTimeoutDuration), onTimeout: () {
      return {'data': {}}.cast<String, dynamic>();
    });
    return eventData.cast<String, dynamic>();
  }

  /// Trigger submission event.
  /// This event will include the current submission.
  Future<Map<String, dynamic>> beforeSubmit(sid, submission) async {
    if (isMock!) {
      return {};
    }
    engineLogger!.d('Submission with submission data ${submission.toString()}');
    var eventData = await eventChannel!.invokeMethod<Map<dynamic, dynamic>>(
        EventIdentifier.submit.name, {
      'sid': sid,
      'data': submission
    }).timeout(Duration(seconds: eventTimeoutDuration), onTimeout: () {
      return {'data': {}}.cast<String, dynamic>();
    });
    return eventData.cast<String, dynamic>();
  }

  /// Trigger input field change event giving the screen [sid], its [binding] identifier and [from] and [to] values.
  Future<Map<String, dynamic>> fieldDidChange(sid, binding, from, to) async {
    if (isMock!) {
      return {};
    }
    var eventData =
        await eventChannel!.invokeMethod<Map<dynamic, dynamic>>(EventIdentifier.fieldDidChange.name, {
      'sid': sid,
      'data': {
        'field': binding,
        'from': from,
        'to': to,
      },
    }).timeout(Duration(seconds: eventTimeoutDuration), onTimeout: () {
      return {'data': {}}.cast<String, dynamic>();
    });
    return eventData.cast<String, dynamic>();
  }
}
