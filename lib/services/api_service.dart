import 'package:flutter/foundation.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/models/api.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

class ApiService {
  final NssChannels channels;

  final _defaultTimeout = 30;

  ApiService(this.channels);

  /// Trigger a native SDK API call given the [method] endpoint and relevant [params] map.
  Future<ApiBaseResult> send(String method, Map<String, dynamic> params) async {
    return await channels.apiChannel.invokeMapMethod(method, params).then((map) {
      //TODO: Add try/catch for parsing error.
      final dataMap = map.cast<String, dynamic>();
      final result = ApiBaseResult.fromJson(dataMap);
      result.data = dataMap;
      return result;
    }).catchError((dynamic error) {
      engineLogger.d('Invocation error with: ${error.message}');
      return throw ApiBaseResult.platformException(error);
    }).timeout(Duration(seconds: configTimeout(method)), onTimeout: () {
      return ApiBaseResult.timedOut();
    });
  }

  /// Timeout can vary with specific flows.
  int configTimeout(String method) {
    switch (method) {
      case 'socialLogin':
        return 300;
      default:
        return _defaultTimeout;
    }
  }
}
