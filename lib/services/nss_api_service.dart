import 'package:flutter/cupertino.dart';
import 'package:gigya_native_screensets_engine/models/api.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

class ApiService {
  final NssChannels channels;

  final _defaultTimeout = 30;

  ApiService({
    @required this.channels,
  });

  Future<ApiBaseResult> send(String method, Map<String, dynamic> params) async {
    return await channels.apiChannel.invokeMapMethod(method, params).then((map) {
      //TODO: Add try/catch for parsing error.
      final dataMap = map.cast<String, dynamic>();
      final result = ApiBaseResult.fromJson(dataMap);
      result.data = dataMap;
      return result;
    }).catchError((error) {
      nssLogger.d('Invocation error with: ${error.message}');
      return ApiBaseResult.platformException(error);
    }).timeout(Duration(seconds: _defaultTimeout), onTimeout: () {
      return ApiBaseResult.timedOut();
    });
  }
}
