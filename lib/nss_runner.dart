import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/components/nss_form.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';

enum NssAlignment { vertical, horizontal }

class NssLayoutBuilder {
  final String _screenId;

  NssLayoutBuilder(this._screenId);

  /// Main rendering action providing screen map & requested screen id.
  Widget render(Map<String, Screen> screenMap) {
    if (screenMap.unavailable(_screenId)) {
      return NssErrorWidget.routeMissMatch();
    }

    final Screen screen = screenMap[_screenId];
    if (screen.children.isNullOrEmpty()) {
      return NssErrorWidget.screenWithNotChildren();
    }

    final List<NssWidgetData> children = screen.children;
    return _build(
      screen,
      _renderWidgets(children),
    );
  }

  Widget _build(Screen screen, List<Widget> list) {
    //TODO: Hardcoded to Material!!!
    return Scaffold(
      appBar: screen.appBar != null
          ? AppBar(
              title: Text(screen.appBar['textKey']),
            )
          : null,
      body: SafeArea(
        child: NssForm(
          screenId: screen.id,
          layoutForm: () => _groupBy(screen.align, list,),
        ),
      ),
    );
  }

  List<Widget> _renderWidgets(List<NssWidgetData> children) {
    List<Widget> widgets = [];

    if (children.isEmpty) {
      return widgets;
    }

    children.forEach((widget) {
      if (widget.children != null) {
        widgets.add(
          _groupBy(
            widget.stack,
            _renderWidgets(widget.children),
          ),
        );
      } else {
        widgets.add(
          NssWidgetFactory().create(widget.type, widget),
        );
      }
    });
    return widgets;
  }

  /// Render list according to provided alignment property.
  Widget _groupBy(NssAlignment alignment, List list) {
    //TODO: Row & Column widgets are highly customizable. Don't forget.
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

//TODO: Move extensions to an extension specific file?

extension IterableExt on Iterable {
  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }
}

extension MapExt<T, V> on Map<T, V> {
  bool unavailable(T key) {
    return !this.containsKey(key);
  }
}
