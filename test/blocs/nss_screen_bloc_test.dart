
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_api_service_bloc.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';

void main() {
  group('Screen bloc tests', () {
    test('Tes successfuly request', () {
      runApp(MaterialApp(home: Container()));

      final List<MethodCall> log = <MethodCall>[];

      final Map<dynamic, dynamic> params = {
        'statusCode': 200,
        'errorCode': 0,
        'callId': '1234',
        'errorMessage': 'ok'
      };

      registry.channels.apiChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return params;
      });
    });
  });
}