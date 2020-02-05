import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_state_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:provider/provider.dart';

class NssSubmitWidget extends StatefulWidget {
  final NssWidgetData data;

  const NssSubmitWidget({Key key, @required this.data}) : super(key: key);

  @override
  _NssSubmitWidgetState createState() => _NssSubmitWidgetState();
}

class _NssSubmitWidgetState extends NssStatefulPlatformWidgetState<NssSubmitWidget>
    with NssWidgetDecorationMixin {
  @override
  void initState() {
    super.initState();

    nssLogger.d('Rendering NssSubmitWidget with id: ${widget.data.id}');
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Padding(
      padding: defaultPadding(),
      child: ButtonTheme(
        //TODO: Update theme decorations here.
        child: RaisedButton(
          child: Text(widget.data.textKey),
          onPressed: () {
            _onSubmit();
          },
        ),
      ),
    );
  }

  /// Perform per submission actions.
  _onSubmit() {
    // Trigger form validation.
    var formBloc = Provider.of<NssFormBloc>(context, listen: false);
    if (formBloc.validateForm()) {
      //TODO: From validated.

      // Action submitted.
      _onActionSubmitted();
    }
  }

  /// Submission (action) widget has the option to request a screen loading state.
  /// When an action is submitted it is required to update the form state to a "loading" state.
  /// Setting the form back to its idle state is handled higher in the hierarchy.
  _onActionSubmitted() {
    Provider.of<NssScreenStateBloc>(context).setProgress();
  }
}
