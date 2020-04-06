import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_scaffold.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/providers/nss_binding_bloc.dart';
import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';
import 'package:provider/provider.dart';

class NssScreenWidget extends StatefulWidget {
  final Screen screen;
  final NssConfig config;
  final NssChannels channels;
  final NssScreenViewModel viewModel;
  final NssScaffoldWidget scaffold;
  final BindingModel bindings;

  const NssScreenWidget({
    Key key,
    @required this.screen,
    @required this.config,
    @required this.channels,
    @required this.viewModel,
    @required this.scaffold,
    @required this.bindings,
  }) : super(key: key);

  @override
  _NssScreenWidgetState createState() => _NssScreenWidgetState();
}

class _NssScreenWidgetState extends State<NssScreenWidget> with NssWidgetDecorationMixin {
  @override
  void initState() {
    super.initState();

    widget.viewModel.id = widget.screen.id;
    // Reference screen view model.
    _attachScreenAction();
    _registerNavigationSteam();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NssScreenViewModel>(
          create: (_) => widget.viewModel,
        ),
        ChangeNotifierProvider<BindingModel>(
          create: (_) => widget.bindings,
        ),
      ],
      child: widget.scaffold,
    );
  }

  /// Register view model instance to a navigation steam controller.
  /// Only the current context contains the main Navigator instance. Therefore we must communicate back to the
  /// screen widget in order to perform navigation actions.
  _registerNavigationSteam() {
    widget.viewModel.navigationStream.stream.listen((route) {
      Navigator.pushReplacementNamed(context, route);
    });
  }

  /// Attach the relevant screen action.
  /// This will result in the instantiation of the native controller action model which will handle all
  /// the native SDK logic.
  _attachScreenAction() async {
    var screenDataMap = await widget.viewModel.attachScreenAction(widget.screen.action);
    widget.bindings.updateWith(screenDataMap);
  }
}
