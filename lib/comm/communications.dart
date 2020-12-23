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
  Future<Map<K, V>> invokeMapMethod<K, V>(String method, [dynamic arguments]) async {
    var data = {
      'method': method,
      'data': arguments,
    };
    html.window.parent.postMessage(jsonEncode(data), '*');
    html.window.addEventListener(
      'message',
      (event) {
        // Remove listener.
        debugPrint(event.toString());
        var json = jsonDecode(event.toString()).cast<String, dynamic>();
        return json;
      },
    );
    //TODO: Check if thread is locked.
    return Future.delayed(Duration(seconds: 120), () => {});
  }
}
