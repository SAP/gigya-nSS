import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:provider/provider.dart';

typedef Widget LayoutNssForm();

class NssFormWidget extends StatefulWidget {
  final String screenId;
  final LayoutNssForm layoutForm;

  const NssFormWidget({Key key, @required this.screenId, @required this.layoutForm}) : super(key: key);

  @override
  _NssFormWidgetState createState() => _NssFormWidgetState();
}

class _NssFormWidgetState extends State<NssFormWidget> {
  GlobalKey<FormState> _formKey;

  GlobalKey key = new Key('key');

  @override
  void initState() {
    super.initState();

    debugPrint('$runtimeType with id: ${widget.screenId} form initState() called');

    // Create form global key.
    _formKey = GlobalKey<FormState>(debugLabel: '$runtimeType with screenId : ${widget.screenId}');

    // Register key in Form registry.
    //TODO: Migrate to form block.
    Provider.of<NssRegistryBloc>(context, listen: false)
        .forms
        .addFormKey(widget.screenId, _formKey);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: widget.layoutForm(),
    );
  }


}
