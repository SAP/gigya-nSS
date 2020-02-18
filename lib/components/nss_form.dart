import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
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

  @override
  void initState() {
    super.initState();

    debugPrint('$runtimeType with id: ${widget.screenId} form initState() called');
    // Create form global key. Will be registered in bloc.
    _formKey = GlobalKey<FormState>(debugLabel: '$runtimeType with screen id : ${widget.screenId}');
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Need to pass the screen action sink to the form block to allow it to communicate with the screen bloc.
    return Provider(
      create: (_) => NssFormBloc(
        _formKey,
        widget.screenId,
        Provider.of<NssScreenViewModel>(context).streamEventSink,
      ),
      child: Form(
        key: _formKey,
        child: widget.layoutForm(),
      ),
    );
  }
}
