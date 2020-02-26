import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
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

  @override
  void initState() {
    super.initState();

    viewModel = Provider.of<NssScreenViewModel>(context, listen: false);

    _requestFlowCoordinationSupport();
    _registerToNavigationStream();
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createScaffold(widget.screen);
  }

  /// Every screen requires a flow coordinator to be initiated in the native side.
  _requestFlowCoordinationSupport() async {
    if (widget.config.isMock) {
      return;
    }
    try {
      bool coordinated = await widget.channels.mainChannel.invokeMethod<bool>(
        'flow',
        {'flowId': widget.screen.flow},
      );
      if (!coordinated) {
        nssLogger.d('Failed to initiate flow coordination');
      }
    } on MissingPluginException catch (e) {
      nssLogger.e('Missing channel connection: check mock state?');
    }
  }

  _registerToNavigationStream() {
    viewModel.navigationStream.stream.listen((route) {
      Navigator.pushNamed(context, route);
    });
  }
}
