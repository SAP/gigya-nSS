import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_binding_bloc.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:provider/provider.dart';

class NssScreenWidget extends StatefulWidget {
  final Screen screen;
  final NssConfig config;
  final NssChannels channels;
  final NssWidgetFactory widgetFactory;

  const NssScreenWidget({
    Key key,
    @required this.screen,
    @required this.config,
    @required this.channels,
    @required this.widgetFactory,
  }) : super(key: key);

  @override
  _NssScreenWidgetState createState() => _NssScreenWidgetState();
}

class _NssScreenWidgetState extends State<NssScreenWidget> with NssWidgetDecorationMixin {
  NssScreenViewModel viewModel;
  BindingModel bindings = BindingModel();

  @override
  void initState() {
    super.initState();

    // Reference view model.
    viewModel = Provider.of<NssScreenViewModel>(context, listen: false);
    _registerToNavigationStream();
    _registerFlow();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BindingModel>(
        create: (_) => bindings, child: widget.widgetFactory.createScaffold(widget.screen));
  }

  _registerToNavigationStream() {
    viewModel.navigationStream.stream.listen((route) {
      Navigator.pushReplacementNamed(context, route);
    });
  }

  _registerFlow() async {
    var screenDataMap = await viewModel.registerFlow(widget.screen.action);
    bindings.updateWith(screenDataMap);
  }
}
