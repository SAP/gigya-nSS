import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:provider/provider.dart';

enum ScreenChannelAction { flow, submit }

extension ScreenChannelActionExt on ScreenChannelAction {
  String get action {
    return describeEnum(this);
  }
}

abstract class ScreenWidgetState<T extends StatefulWidget> extends State<T>
    with ScreenEventHandler {
  final ScreenViewModel viewModel;
  final BindingModel bindings;

  ScreenWidgetState(this.viewModel, this.bindings);

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
      ],
      child: buildScaffold(),
    );
  }

  Widget buildScaffold();
}

mixin ScreenEventHandler {
  final MethodChannel eventChannel = NssIoc().use(NssChannels).eventsChannel;

  /// Trigger first screen load event.
  /// This event will only occur after the first screen state build.
  void screenDidLoad(sid) {
    engineLogger.d('Screen did load for $sid');
    eventChannel.invokeMethod<void>('screenDidLoad', {'sid': sid});
  }
}
