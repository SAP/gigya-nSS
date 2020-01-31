import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/dynamic/nss_action_widgets.dart';
import 'package:gigya_native_screensets_engine/components/dynamic/nss_input_widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';

import 'components/dynamic/nss_label_widgets.dart';

enum NssWidgetType { label, input, email, password, submit }

class NssWidgetFactory {
  Widget create(NssWidgetType type, NssWidgetData data) {
    switch (type) {
      case NssWidgetType.label:
        return NssLabelWidget(widgetData: data);
      case NssWidgetType.input:
      case NssWidgetType.email:
      case NssWidgetType.password:
        //TODO GlobalKey should be fetched from the FormRegistry. Remove from constructor.
        return NssTextInputWidget(formKey: GlobalKey(), widgetData: data);
      case NssWidgetType.submit:
        return NssSubmitWidget(widgetData: data);
        break;
    }
    return Container();
  }
}
