import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

//region Label Widget (Simple)

class NssLabelWidget extends NssStatelessPlatformWidget with NssWidgetDecorationMixin {
  final NssWidgetData data;

  NssLabelWidget({this.data});

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    nssLogger.d('Rendering NssTextInputWidget with id: ${data.id}');
    return Padding(
      padding: defaultPadding(),
      child: Text(
        data.textKey,
        //TODO: Style text here.
        style: TextStyle(),
      ),
    );
  }
}

//endregion
