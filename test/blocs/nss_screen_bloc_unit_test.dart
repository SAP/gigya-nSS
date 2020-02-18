import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';
import 'package:test/test.dart';

void main() {
  group('Screen bloc tests', () {
    test('Tes successfuly request', () {
      runApp(MaterialApp(home: Container()));

      final List<MethodCall> log = <MethodCall>[];

      final Map<dynamic, dynamic> params = {'statusCode': 200, 'errorCode': 0, 'callId': '1234', 'errorMessage': 'ok'};

      registry.channels.apiChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return params;
      });
    });
  });
}
