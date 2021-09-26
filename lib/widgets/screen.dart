import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/widgets/events.dart';
import 'package:provider/provider.dart';

enum ScreenChannelAction { flow, submit }

extension ScreenChannelActionExt on ScreenChannelAction {
  String get action {
    return describeEnum(this);
  }
}

abstract class ScreenWidgetState<T extends StatefulWidget> extends State<T>
    with EngineEvents {
  final ScreenViewModel viewModel;
  final BindingModel bindings;
  final RuntimeStateEvaluator expressionProvider;

  ScreenWidgetState(this.viewModel, this.bindings, this.expressionProvider);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScreenViewModel>(
          create: (_) => viewModel,
        ),
        ChangeNotifierProvider<BindingModel>(
          create: (_) => bindings,
        ),
        ChangeNotifierProvider<RuntimeStateEvaluator>(
          create: (_) => expressionProvider,
        )
      ],
      child: buildScaffold(),
    );
  }

  Widget buildScaffold();
}
