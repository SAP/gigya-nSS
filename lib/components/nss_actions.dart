import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/providers/nss_binding_bloc.dart';
import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:provider/provider.dart';

mixin NssActionsMixin {
  /// Call to dismiss keyboard from current focusable input component.
  dismissKeyboardWith(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}

class NssSubmitWidget extends StatefulWidget {
  final NssConfig config;
  final NssWidgetData data;

  const NssSubmitWidget({
    Key key,
    @required this.config,
    @required this.data,
  }) : super(key: key);

  @override
  _NssSubmitWidgetState createState() => _NssSubmitWidgetState(isPlatformAware: config.isPlatformAware);
}

class _NssSubmitWidgetState extends NssPlatformState<NssSubmitWidget> with NssWidgetDecorationMixin, NssActionsMixin {
  final bool isPlatformAware;

  _NssSubmitWidgetState({
    @required this.isPlatformAware,
  }) : super(isPlatformAware: isPlatformAware);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: defaultPadding(),
        child: Consumer2<NssScreenViewModel, BindingModel>(
          builder: (context, viewModel, bindings, child) {
            return RaisedButton(
              child: Text(widget.data.textKey),
              onPressed: () {
                viewModel.submitScreenForm(bindings.bindingData);

                // Dismiss the keyboard. Important.
                dismissKeyboardWith(context);
              },
            );
          },
        ),
      ),
    );
  }
}
