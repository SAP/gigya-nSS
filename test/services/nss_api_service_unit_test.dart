import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/services/nss_api_service.dart';
import 'package:test/test.dart';

void main() {

  group('Request with api channel tests', () {
//    test('Tes successfuly request', () {
//      runApp(MaterialApp(home: Container()));
//
//      final List<MethodCall> log = <MethodCall>[];
//
//      final Map<dynamic, dynamic> params = {'statusCode': 200, 'errorCode': 0, 'callId': '1234', 'errorMessage': 'ok'};
//
//      final method = 'test';
//
//      final apiService = ApiService();
//
//      registry.channels.apiChannel.setMockMethodCallHandler((MethodCall methodCall) async {
//        log.add(methodCall);
//        return params;
//      });
//
//      apiService.send(method, {}).then((result) {
//        expect(result.statusCode, 200);
//        expect(result.isSuccess(), true);
//      });
//    });
//
//    test('Test fail request', () {
//      runApp(MaterialApp(home: Container()));
//
//      final List<MethodCall> log = <MethodCall>[];
//
//      final Map<dynamic, dynamic> params = {
//        'statusCode': 200,
//        'errorCode': 200061,
//        'callId': '1234',
//        'errorMessage': 'error'
//      };
//
//      final method = 'test';
//
//      final apiService = ApiService();
//
//      registry.channels.apiChannel.setMockMethodCallHandler((MethodCall methodCall) async {
//        log.add(methodCall);
//        return params;
//      });
//
//      apiService.send(method, {}).then((result) {
//        expect(result.statusCode, 200);
//        expect(result.isSuccess(), false);
//      });
//    });
//
//    test('Test bad request - parser error', () {
//      runApp(MaterialApp(home: Container()));
//
//      final List<MethodCall> log = <MethodCall>[];
//
//      final Map<dynamic, dynamic> params = {'test': 200061};
//
//      final method = 'test';
//
//      final apiService = ApiService();
//
//      registry.channels.apiChannel.setMockMethodCallHandler((MethodCall methodCall) async {
//        log.add(methodCall);
//        return params;
//      });
//
//      apiService.send(method, {}).then((result) {}).catchError((error) {
//            expect(error.toString(), isNotEmpty);
//          });
//    });
  });
}
