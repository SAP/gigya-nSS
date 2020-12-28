import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';

mixin DebugUtils {
  void postDelayed(seconds, Function action) {
    Future.delayed(Duration(seconds: seconds), () {
      action();
    });
  }
}

/// Widget is used to add a "watermark" like tag on the bottom right of the screen that indicates
/// That the engine is using mock markup setup.
class NssDebugDecorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: new BoxDecoration(
            color: Colors.grey.withOpacity(0.7),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              'Uses mock',
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.indigo[400],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
