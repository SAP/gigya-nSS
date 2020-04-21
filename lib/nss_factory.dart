import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'package:gigya_native_screensets_engine/providers/nss_binding_bloc.dart';
import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';

/// Available widget types supported by the Nss engine.
enum NssWidgetType {
  screen,
  container,
  label,
  input,
  email,
  password,
  submit,
  checkbox,
}

extension NssWidgetTypeExt on NssWidgetType {
  String get name => describeEnum(this);
}

/// Directional layout alignment widget for "stack" markup property.
enum NssStack { vertical, horizontal }

/// Multi widget container alignment options for "alignment" markup property.
enum NssAlignment { start, end, center, equal_spacing, spread }

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
    return NssScreenWidget(
      screen: screen,
      config: config,
      channels: channels,
      viewModel: NssInjector().use(NssScreenViewModel),
      scaffold: createScaffold(screen),
      bindings: NssInjector().use(BindingModel),
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
      child: _groupBy(_buildWidgets(screen.children), screen.stack),
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
      case NssWidgetType.checkbox:
        break;
      default:
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
      if (widget.type == NssWidgetType.container) {
        // View group required.
        widgets.add(
          _groupBy(
            _buildWidgets(widget.children),
            widget.stack,
            alignment: widget.alignment,
          ),
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
  Widget _groupBy(List<Widget> list, NssStack stack, {NssAlignment alignment}) {
    if (stack == null) {
      //TODO: Should display an error widget here as a part of the stack.
      return Container();
    }
    switch (stack) {
      case NssStack.vertical:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: getMainAxisAlignment(alignment),
          children: list,
        );
      case NssStack.horizontal:
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: getMainAxisAlignment(alignment),
          children: list,
        );
      default:
        return Column(children: list);
    }
  }

  /// [Flex] Widgets such as [Column] and [Row] require alignment property in order
  /// to better understand where their child widgets are will layout.
  MainAxisAlignment getMainAxisAlignment(NssAlignment alignment) {
    if (alignment == null) return MainAxisAlignment.start;
    switch (alignment) {
      case NssAlignment.start:
        return MainAxisAlignment.start;
      case NssAlignment.end:
        return MainAxisAlignment.end;
      case NssAlignment.center:
        return MainAxisAlignment.center;
      case NssAlignment.equal_spacing:
        return MainAxisAlignment.spaceEvenly;
      case NssAlignment.spread:
        return MainAxisAlignment.spaceBetween;
      default:
        return MainAxisAlignment.start;
    }
  }
}
