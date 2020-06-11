import 'package:flutter/services.dart' show rootBundle;

class AssetUtils {
  /// Read JSON string from asset file.
  static Future<String> jsonFromAssets(assetsPath) async {
    print('--- Parse json from: $assetsPath');
    return rootBundle.loadString(assetsPath);
  }
}
