import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class AssetUtils {
  static Future<Map<String, dynamic>> jsonMapFromAssets(assetsPath) async {
    print('--- Parse json from: $assetsPath');
    return rootBundle.loadString(assetsPath).then((jsonStr) => jsonDecode(jsonStr));
  }
}
