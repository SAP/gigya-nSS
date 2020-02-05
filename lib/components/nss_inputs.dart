import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:provider/provider.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';

class NssTextInputWidget extends StatefulWidget {
  final NssWidgetData data;

  const NssTextInputWidget({Key key, @required this.data}) : super(key: key);

  @override
  _NssTextInputWidgetState createState() => _NssTextInputWidgetState();
}

class _NssTextInputWidgetState extends NssStatefulPlatformWidgetState<NssTextInputWidget>
    with NssWidgetDecorationMixin {
  final TextEditingController controller = TextEditingController();

  GlobalKey wKey;

  @override
  void initState() {
    super.initState();

    nssLogger.d('Rendering NssTextInputWidget with id: ${widget.data.id}');

    /// Create and register a global key for input field in order to allow global editing reference.
    wKey = GlobalKey(debugLabel: '$runtimeType with widget id : ${widget.data.id}');
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    Provider.of<NssFormBloc>(context).addChildWith(wKey, forId: widget.data.id);
    return Padding(
      padding: defaultPadding(),
      child: TextFormField(
        key: wKey,
        controller: controller,
        decoration: InputDecoration(hintText: widget.data.textKey),
        validator: (input) {
          //TODO: Take in mind that we will need to think how we will be injecting custom field validations here as well.
          return _validateField(input);
        },
      ),
    );
  }

  /// Validate input according to instance type.
  String _validateField(input) {
    var validated =
        Provider.of<NssFormBloc>(context, listen: false).validate(input, forType: widget.data.type.name);
    if (validated == NssInputValidation.failed) {
      //TODO: Validation errors should be injected via the localization map.
      return 'Validation faild for type: ${widget.data.type.name}';
    } else if (validated == NssInputValidation.na) {
      nssLogger.d('Validator not specified for input widget type');
    }
    return null;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
