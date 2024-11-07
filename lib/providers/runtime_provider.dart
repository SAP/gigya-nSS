import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:provider/provider.dart';

class RuntimeStateEvaluator with ChangeNotifier {
  /// Notify value changed in widget state.
  /// This will trigger visibility checks for all widgets that are registered.
  void notifyChanged(String? bindField, dynamic value) {
    // Notify all listeners that register to get runtime change notifications.
    notifyListeners();
  }
}

mixin VisibilityStateMixin {
  /// Register widget to receive updates only when they contain a "showIf" property.
  void registerVisibilityNotifier(
      BuildContext context, NssWidgetData? data, VoidCallback callback) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    final RuntimeStateEvaluator runtimeProvider =
        Provider.of<RuntimeStateEvaluator>(context, listen: false);

    if (data!.showIf != null) {
      runtimeProvider.addListener(
        () async {
          engineLogger.d(
              'Widget with bind "${data.bind}" notified to evaluate showIf state');

          // Request runtime evaluation of the showIf expression according to current
          // Tracked changes and trigger a state change for this widget.
          ScreenViewModel viewModel = NssIoc().use(ScreenViewModel);

          BindingModel binding = NssIoc().use(BindingModel);

          await viewModel.evaluateExpressionByDemand(
              data, binding.savedBindingData);

          // Expression updated. Notify widget to set its state by demand.
          callback.call();
        },
      );
    }
    // });
  }
}
