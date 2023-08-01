import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Custom screen progress widget.
/// Will be displayed on top of the screen stack when the screen state is in progress.
class ScreenProgressWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
      ),
      child: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }
}
