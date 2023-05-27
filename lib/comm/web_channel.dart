import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

import '../config.dart';
import 'mobile_channel.dart';

class WebChannels extends NssChannels {
  WebChannels()
      : super(
          NssWebMethodChannel('ignition'),
          NssWebMethodChannel('screen'),
          NssWebMethodChannel('api'),
          NssWebMethodChannel('log'),
          NssWebMethodChannel('data'),
          NssWebMethodChannel('events'),
        );
}

class NssWebMethodChannel extends NssChannel {
  final String channel;

  NssWebMethodChannel(this.channel);

  Future<T> invokeMethod<T>(String method, [dynamic arguments]) async {
    var data = {
      'channel': channel,
      'method': method,
      'data': arguments ?? {},
    };
    var encoded = jsonEncode(data);
    window.parent!.postMessage(encoded, '*');
    MessageEvent msg = await window.onMessage.firstWhere((element) {
      var json = jsonDecode(element.data).cast<String, dynamic>();
      debugPrint(json['method']);
      if (json['method'] == null) {
        return true;
      } else {
        return false;
      }
    });
    var json = jsonDecode(msg.data).cast<String, dynamic>();
    if (json['details'] != null) {
      return Future.error(PlatformException(code: json['code'], message: json['message'], details: json['details']));
    }
    return json;

  }

  Future<Map<K, V>> invokeMapMethod<K, V>(String method, [dynamic arguments]) async {
    var data = {
      'channel': channel,
      'method': method,
      'data': arguments ?? {},
    };
    var encoded = jsonEncode(data);
    window.parent!.postMessage(encoded, '*');
    MessageEvent msg = await window.onMessage.firstWhere((element) {
      var json = jsonDecode(element.data).cast<String, dynamic>();
      debugPrint(json['method']);
      if (json['method'] == null) {
        return true;
      } else {
        return false;
      }
    });
    var json = jsonDecode(msg.data).cast<String, dynamic>();
    if (json['details'] != null) {
      return Future.error(PlatformException(code: json['code'], message: json['message'], details: json['details']));
    }
    return json;
  }
}