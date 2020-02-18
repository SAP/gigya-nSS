import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_actions.dart';
import 'package:gigya_native_screensets_engine/components/nss_inputs.dart';
import 'package:gigya_native_screensets_engine/components/nss_labels.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';

enum NssWidgetType { label, input, email, password, submit }

extension NssWidgetTypeExt on NssWidgetType {
  String get name => describeEnum(this);
}

class NssWidgetFactory {
  Widget create(NssWidgetType type, NssWidgetData data) {
    switch (type) {
      case NssWidgetType.label:
        return NssLabelWidget(data: data);
      case NssWidgetType.input:
      case NssWidgetType.email:
      case NssWidgetType.password:
        return NssTextInputWidget(data: data);
      case NssWidgetType.submit:
        return NssSubmitWidget(data: data);
        break;
    }
    return Container();
  }
}
