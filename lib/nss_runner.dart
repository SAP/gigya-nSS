import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/components/nss_screen.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:provider/provider.dart';

import './utils/extensions.dart';

enum NssAlignment { vertical, horizontal }

class NssScreenBuilder {
  final Screen screen;

  NssScreenBuilder(this.screen);

  /// Main rendering action providing screen map & requested screen id.
  Widget build() {
    // Must contain the children tag.
    if (screen.children.isNullOrEmpty()) {
      return NssRenderingErrorWidget.screenWithNotChildren();
    }

    // Must contain a flow.
    if (screen.flow.isNullOrEmpty()) {
      return NssRenderingErrorWidget.missingFlow();
    }

    return _buildScreen(
      screen, // Screen instance.
      _buildWidgets(screen.children), // List<Widget> children.
    );
  }

  /// Layout the screen widget.
  /// Create the root [NssScreenWidget] screen instance.
  Widget _buildScreen(Screen screen, List<Widget> list) {
    return ChangeNotifierProvider<NssScreenViewModel>(
      create: (_) => NssScreenViewModel(
        screen.id,
      ),
      child: NssScreenWidget(
        screen: screen,
        layoutScreen: () => _groupBy(screen.align, list), // Form layout must begin with a view group.
      ),
    );
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
          NssWidgetFactory().create(widget.type, widget),
        );
      }
    });
    return widgets;
  }

  /// Group given widget [list] according to required view group [NssAlignment] alignment property.
  /// Currently supports [Column] for vertical alignment and [Row] for horizontal alignment.
  //TODO: Row & Column widgets are highly customizable. Don't forget.
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
