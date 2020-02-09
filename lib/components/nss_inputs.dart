import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:provider/provider.dart';

//region TextInput

class NssTextInputWidget extends StatefulWidget {
  final NssWidgetData data;

  const NssTextInputWidget({Key key, @required this.data}) : super(key: key);

  @override
  _NssTextInputWidgetState createState() => _NssTextInputWidgetState();
}

class _NssTextInputWidgetState extends NssStatefulPlatformWidgetState<NssTextInputWidget> with NssWidgetDecorationMixin {

  final TextEditingController _textEditingController = TextEditingController();

  GlobalKey wKey;

  @override
  void initState() {
    super.initState();

    nssLogger.d('Rendering NssTextInputWidget with id: ${widget.data.id}');

    // Create and register a global key for input field in order to allow global editing reference.
    wKey = GlobalKey(debugLabel: '$runtimeType with widget id : ${widget.data.id}');

    // Register the widget's global key/id to the form block to allow reference tracking.
    // This is intended for submission logic usage.
    Provider.of<NssFormBloc>(context, listen: false).addInputWith(wKey, forId: widget.data.id);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
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
      child: TextFormField(
        key: wKey,
        controller: _textEditingController,
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
    var validated = Provider.of<NssFormBloc>(context, listen: false).validate(input, forType: widget.data.type.name);

    switch (validated) {
      case NssInputValidation.failed:
        //TODO: Validation errors should be injected via the localization map.
        return 'Validation faild for type: ${widget.data.type.name}';
      case NssInputValidation.na:
        //TODO: Not available validator error should be injected via the localization map.
        nssLogger.d('Validator not specified for input widget type');
        break;
      case NssInputValidation.passed:
        break;
    }
    return null;
  }
}

//endregion
