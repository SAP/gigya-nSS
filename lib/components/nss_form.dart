import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_form_bloc.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:provider/provider.dart';

class NssFormWidget extends StatefulWidget {
  final String screenId;
  final Widget child;
  final NssFormBloc bloc;

  const NssFormWidget({
    Key key,
    @required this.screenId,
    @required this.child,
    @required this.bloc,
  }) : super(key: key);

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
    return Provider(
      create: (_) => _provideBloc(),
      child: Form(
        key: _formKey,
        child: widget.child,
      ),
    );
  }

  NssFormBloc _provideBloc() {
    widget.bloc.formKey = _formKey;
    widget.bloc.screenId = widget.screenId;
    widget.bloc.screenSink = Provider.of<NssScreenViewModel>(context).streamEventSink;
    return widget.bloc;
  }
}
