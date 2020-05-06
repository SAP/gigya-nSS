import 'package:flutter/foundation.dart';
import 'package:gigya_native_screensets_engine/config.dart';

class ScreenService {
  final NssChannels channels;

  final _defaultTimeout = 30;

  ScreenService(this.channels);

  Future<Map<String, dynamic>> initiateAction(String actionId, String screenId) async {
    var map = await channels.screenChannel.invokeMethod<Map<dynamic, dynamic>>(
      'action',
      {'actionId': actionId, 'screenId': screenId},
    ).catchError((error) {
      return {};
    }).timeout(Duration(seconds: _defaultTimeout), onTimeout: () {
      return {};
    });
    return map.cast<String, dynamic>();
  }
}
