import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_action_widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_input_widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';

import 'components/nss_label_widgets.dart';

enum NssWidgetType { label, input, email, password, submit }

class NssWidgetFactory {
  // TODO: Add formKey to create.
  Widget create(NssWidgetType type, NssWidgetData data) {
    switch (type) {
      case NssWidgetType.label:
        // TODO: Handle this case.
        return NssLabelWidget(widgetData: data);
      case NssWidgetType.input:
      case NssWidgetType.email:
      case NssWidgetType.password:
        return NssTextInputWidget(formKey: GlobalKey(), widgetData: data);
      case NssWidgetType.submit:
        return NssSubmitWidget(widgetData: data);
        break;
    }
    return Container();
  }
}
