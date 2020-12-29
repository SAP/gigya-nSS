import 'dart:async';
import 'dart:convert';


import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/config.dart';

class ChannelManager {}

class MobileChannels extends NssChannels {
  MobileChannels()
      : super(
          NssMobileMethodChannel('gigya_nss_engine/method/ignition') as NssChannel,
          NssMobileMethodChannel('gigya_nss_engine/method/screen') as NssChannel,
          NssMobileMethodChannel('gigya_nss_engine/method/screen') as NssChannel,
          NssMobileMethodChannel('gigya_nss_engine/method/log') as NssChannel,
          NssMobileMethodChannel('gigya_nss_engine/method/data') as NssChannel,
          NssMobileMethodChannel('gigya_nss_engine/method/events') as NssChannel,
        );
}

abstract class NssChannel {
  Future<T> invokeMethod<T>(String method, [ dynamic arguments ]);

  Future<Map<K, V>> invokeMapMethod<K, V>(String method, [dynamic arguments]);
}

class NssMobileMethodChannel extends MethodChannel {
  NssMobileMethodChannel(String name) : super(name);
}

