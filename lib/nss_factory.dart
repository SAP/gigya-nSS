import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_actions.dart';
import 'package:gigya_native_screensets_engine/components/nss_form.dart';
import 'package:gigya_native_screensets_engine/components/nss_inputs.dart';
import 'package:gigya_native_screensets_engine/components/nss_labels.dart';
import 'package:gigya_native_screensets_engine/components/nss_scaffold.dart';
import 'package:gigya_native_screensets_engine/components/nss_screen.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:provider/provider.dart';

/// Available widget types supported by the Nss engine.
enum NssWidgetType { screen, label, input, email, password, submit }

extension NssWidgetTypeExt on NssWidgetType {
  String get name => describeEnum(this);
}

/// Directional alignment widget for "stack" markup property.
enum NssAlignment { vertical, horizontal }

/// Main engine widget creation factory class.
class NssWidgetFactory {
  final NssConfig config;
  final NssChannels channels;

  NssWidgetFactory({
    @required this.config,
    @required this.channels,
  });

  /// Create screen widget.
  /// Every [NssScreenWidget] must be paired with enclosing [NssScreenViewModel] provider that is responsible to handle
  /// the state of the current screen and provide service/repository connections for communication logic.
  Widget createScreen(Screen screen) {
    return ChangeNotifierProvider<NssScreenViewModel>(
      create: (_) {
        final NssScreenViewModel viewModel = NssInjector().use(NssScreenViewModel);
        // Inject screen id to view model.
        viewModel.id = screen.id;
        return viewModel;
      },
      child: NssScreenWidget(
        screen: screen,
        config: config,
        channels: channels,
        widgetFactory: this,
      ),
    );
  }

  /// Create a new instance of the [NssScaffoldWidget] the will contain the main construct of every
  /// displayed screen.
  Widget createScaffold(Screen screen) {
    return NssScaffoldWidget(
      config: config,
      appBarData: screen.appBar != null
          ? NssAppBarData(
              screen.appBar['textKey'] ?? '',
            )
          : null,
      screenBody: createForm(screen),
    );
  }

  /// Create a new instance of the [NssFormWidget] for the relevant [Screen] data.
  Widget createForm(Screen screen) {
    return NssFormWidget(
      screenId: screen.id,
      child: _groupBy(screen.align, _buildWidgets(screen.children)),
    );
  }

  /// Create a new instance widget according to provided [NssWidgetType] and [NssWidgetData] parameters.
  Widget create(NssWidgetType type, NssWidgetData data) {
    switch (type) {
      case NssWidgetType.screen:
      case NssWidgetType.label:
        return NssLabelWidget(config: config, data: data);
      case NssWidgetType.input:
      case NssWidgetType.email:
      case NssWidgetType.password:
        return NssTextInputWidget(config: config, data: data);
      case NssWidgetType.submit:
        return NssSubmitWidget(config: config, data: data);
        break;
    }
    return Container();
  }

  /// Dynamically create component widget or components view group according to children parameter
  /// of the [NssWidgetData] provided.
  List<Widget> _buildWidgets(List<NssWidgetData> children) {
    if (children.isEmpty) {
      return [];
    }

    List<Widget> widgets = [];
    children.forEach((widget) {
      if (widget.hasChildren()) {
        // View group required.
        widgets.add(
          _groupBy(widget.stack, _buildWidgets(widget.children)),
        );
      } else {
        widgets.add(
          create(widget.type, widget),
        );
      }
    });
    return widgets;
  }

  /// Group provided widget list according to [NssAlignment] directional parameter.
  /// Currently supports only [Column] and [Row] group widgets.
  Widget _groupBy(NssAlignment alignment, List<Widget> list) {
    switch (alignment) {
      case NssAlignment.vertical:
        return Column(children: list);
      case NssAlignment.horizontal:
        return Row(children: list);
      default:
        return Column(children: list);
    }
  }
}
