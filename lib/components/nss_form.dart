import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_registry_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_lifecycle_mixins.dart';
import 'package:provider/provider.dart';

typedef Widget LayoutNssForm();

class NssForm extends StatefulWidget {
  final String screenId;
  final LayoutNssForm layoutForm;

  const NssForm({Key key, @required this.screenId, @required this.layoutForm}) : super(key: key);

  @override
  _NssFormState createState() => _NssFormState();
}

class _NssFormState extends State<NssForm> with NssStatefulLifecycleMixin<NssForm> {
  GlobalKey<FormState> _formKey;

  @override
  void onInitState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  void onFirstLayout(BuildContext context) {
    // Register key in Form registry.
    Provider.of<NssRegistryBloc>(context).forms.addFormKey(widget.screenId, _formKey);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: widget.layoutForm(),
    );
  }
}
