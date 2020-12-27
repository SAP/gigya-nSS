import 'dart:async';
import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/config.dart';

class ChannelManager {}

class MobileChannels extends NssChannels {
  MobileChannels()
      : super(
          NssMobileMethodChannel('gigya_nss_engine/method/ignition'),
          NssMobileMethodChannel('gigya_nss_engine/method/screen'),
          NssMobileMethodChannel('gigya_nss_engine/method/screen'),
          NssMobileMethodChannel('gigya_nss_engine/method/log'),
          NssMobileMethodChannel('gigya_nss_engine/method/data'),
          NssMobileMethodChannel('gigya_nss_engine/method/events'),
        );
}

class NssMobileMethodChannel extends MethodChannel {
  NssMobileMethodChannel(String name) : super(name);
}

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

class NssWebMethodChannel {
  Future<T> invokeMethod<T>(String method, [ dynamic arguments ]) async {
    var data = {
      'method': method,
      'data': arguments ?? {},
    };
    html.window.parent.postMessage(jsonEncode(data), '*');
    html.MessageEvent msg = await html.window.onMessage.firstWhere((element) {
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
    html.window.parent.postMessage(jsonEncode(data), '*');
    html.MessageEvent msg = await html.window.onMessage.firstWhere((element) {
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
