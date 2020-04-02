import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/providers/nss_binding_bloc.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:provider/provider.dart';

class NssLabelWidget extends NssPlatformWidget with NssWidgetDecorationMixin, BindingMixin {
  final NssConfig config;
  final NssWidgetData data;

  NssLabelWidget({
    @required this.config,
    @required this.data,
  }) : super(isPlatformAware: config.isPlatformAware);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Padding(
      padding: defaultPadding(),
      child: Consumer<BindingModel>(builder: (context, bindings, child) {
        final bindingText = getText(data, bindings);
        return Text(
          bindingText.isEmpty ? data.textKey : bindingText,
          style: TextStyle(),
        );
      }),
    );
  }
}
