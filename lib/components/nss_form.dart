import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';
import 'package:provider/provider.dart';

class NssFormWidget extends StatefulWidget {
  final String screenId;
  final Widget child;

  const NssFormWidget({
    Key key,
    @required this.screenId,
    @required this.child,
  }) : super(key: key);

  @override
  _NssFormWidgetState createState() => _NssFormWidgetState();
}

class _NssFormWidgetState extends State<NssFormWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: Provider.of<NssScreenViewModel>(context).formKey,
        child: widget.child,
      ),
    );
  }
}
