import 'dart:io';

/// Helper class outside the scope of "flutter_platform_widgets" package.
/// Needed for usage without build context scope requirement.
class PlatformHelper {
  static bool isMaterial() {
    return Platform.isAndroid;
  }

  static bool isCupertino() {
    return Platform.isIOS;
  }
}
