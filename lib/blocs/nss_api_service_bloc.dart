import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/models/api.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';

class ApiServiceBloc {
  final MethodChannel _apiChannel = registry.channels.apiChannel;

  // TODO: would need to remove option to mocked api?
  // mock for testing
  ApiBaseResult mock;

  Future<ApiBaseResult> send(String method, Map<String, dynamic> params) async {
    //TODO: Do not forget to remove it.
    if(mock != null) {
      return mock;
    }

    return await _apiChannel.invokeMapMethod(method, params).then((map) {
      final result = ApiBaseResult.fromJson(map);

      // Implementation the result of success.
      return result;

    }).catchError((error) {
      //TODO: Handler error.
      return error;
    });
  }

}