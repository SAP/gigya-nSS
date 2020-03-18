import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_actions_mixin.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:provider/provider.dart';

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

  NssFormBloc bloc;

  _NssSubmitWidgetState({
    @required this.isPlatformAware,
  }) : super(isPlatformAware: isPlatformAware);

  @override
  void initState() {
    super.initState();

    bloc = Provider.of<NssFormBloc>(context, listen: false);
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Padding(
      //TODO: Using default padding.
      padding: defaultPadding(),
      child: RaisedButton(
        child: Text(widget.data.textKey),
        onPressed: () {
          _onSubmit();
          // Dismiss the keyboard. Important.
          dismissKeyboardWith(context);
        },
      ),
    );
  }

  /// Request form submission.
  _onSubmit() {
    // Trigger form submission.
    bloc.onFormSubmission();
  }
}
