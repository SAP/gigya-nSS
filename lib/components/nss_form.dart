import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:provider/provider.dart';

typedef Widget LayoutNssForm();

class NssForm extends StatefulWidget {
  final String screenId;
  final LayoutNssForm layoutForm;

  const NssForm({Key key, @required this.screenId, @required this.layoutForm}) : super(key: key);

  @override
  _NssFormState createState() => _NssFormState();
}

class _NssFormState extends State<NssForm> {
  GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();

    debugPrint('$runtimeType with id: ${widget.screenId} form initState() called');

    // Create form global key.
    _formKey = GlobalKey<FormState>(debugLabel: '$runtimeType with screenId : ${widget.screenId}');

    // Register key in Form registry.
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
