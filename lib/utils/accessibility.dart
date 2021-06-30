import 'package:flutter/cupertino.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';

class SemanticsWrapperWidget extends StatelessWidget {
  final Accessibility accessibility;
  final Widget child;

  const SemanticsWrapperWidget({Key key, this.accessibility, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (accessibility == null) return child;
    if (accessibility.label.isNotEmpty) {
      debugPrint(accessibility.label);
    }
    return Semantics(
      label: accessibility.label.isNotEmpty ? accessibility.label : null,
      hint: accessibility.hint.isNotEmpty ? accessibility.hint : null,
      child: child,
    );
  }
}
