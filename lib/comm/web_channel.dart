
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'communications.dart';


class WebChannels {
  WebChannels();

  NssWebChannels channels;

  factory WebChannels.instance() {
    WebChannels wc = WebChannels();
    wc.channels = NssWebChannels(NssWebMethodChannel());
    return wc;
  }
}


class NssWebChannels extends NssChannels {
  NssWebChannels(channel) : super(channel, channel, channel, channel, channel, channel);
}

class NssWebMethodChannel extends NssChannel {
  Future<T> invokeMethod<T>(String method, [ dynamic arguments ]) async {
    var data = {
      'method': method,
      'data': arguments ?? {},
    };
    window.parent.postMessage(jsonEncode(data), '*');
    MessageEvent msg = await window.onMessage.firstWhere((element) {
      var json = jsonDecode(element.data).cast<String, dynamic>();
      debugPrint(json["method"]);
      if (json["method"] == null) {
        return true;
      } else {
        return false;
      }
    });
    var json = jsonDecode(msg.data).cast<String, dynamic>();
    return json;
  }

  Future<Map<K, V>> invokeMapMethod<K, V>(String method, [dynamic arguments]) async {
    var data = {
      'method': method,
      'data': arguments ?? {},
    };
    window.parent.postMessage(jsonEncode(data), '*');
    MessageEvent msg = await window.onMessage.firstWhere((element) {
      var json = jsonDecode(element.data).cast<String, dynamic>();
      debugPrint(json["method"]);
      if (json["method"] == null) {
        return true;
      } else {
        return false;
      }
    });
    var json = jsonDecode(msg.data).cast<String, dynamic>();
    return json;
  }
}