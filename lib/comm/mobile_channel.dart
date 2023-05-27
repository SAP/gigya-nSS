import 'dart:async';


import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/config.dart';

class MobileChannels extends NssChannels {
  MobileChannels()
      : super(
          NssMobileMethodChannel('gigya_nss_engine/method/ignition'),
          NssMobileMethodChannel('gigya_nss_engine/method/screen'),
          NssMobileMethodChannel('gigya_nss_engine/method/api'),
          NssMobileMethodChannel('gigya_nss_engine/method/log'),
          NssMobileMethodChannel('gigya_nss_engine/method/data'),
          NssMobileMethodChannel('gigya_nss_engine/method/events'),
        );
}

abstract class NssChannel {
  Future<T> invokeMethod<T>(String method, [ dynamic arguments ]);

  Future<Map<K, V>?> invokeMapMethod<K, V>(String method, [dynamic arguments]);
}

class NssMobileMethodChannel extends NssChannel {
  late MethodChannel channel;

  NssMobileMethodChannel(String name) {
    channel = MethodChannel(name);
  }

  @override
  Future<Map<K, V>?> invokeMapMethod<K, V>(String method, [arguments]) async {
    return await channel.invokeMapMethod(method, arguments);
  }

  @override
  Future<T> invokeMethod<T>(String method, [arguments]) async {
    return await channel.invokeMethod(method, arguments);
  }
}

