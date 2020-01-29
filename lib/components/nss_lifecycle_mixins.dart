import 'package:flutter/widgets.dart';

mixin NssStatefulLifecycleMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    onInitState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onFirstLayout(context));
  }

  /// Optional tasks to be performed right after the widget's initState() is called.
  void onInitState();

  /// Optional tasks to be performed right after the widget's layout is build for the first time.
  void onFirstLayout(BuildContext context);
}
