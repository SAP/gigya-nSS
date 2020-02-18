import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/models/api.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

class ApiService {
  final MethodChannel _api = registry.channels.apiChannel;

  Future<ApiBaseResult> send(String method, Map<String, dynamic> params) async {
    return await _api.invokeMapMethod(method, params).then((map) {
      final result = ApiBaseResult.fromJson(map.cast<String, dynamic>());
      return result;
    }).catchError((error) {
      nssLogger.d('Invocation error with: ${error.message}');
      return ApiBaseResult.platformException(error);
    });
  }
}
