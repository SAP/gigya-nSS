import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_injection.dart';

enum NssAlignment { vertical, horizontal }

class NssLayoutBuilder {
  final String layoutName;

  NssLayoutBuilder(this.layoutName);

  // The render method should be render the json to one Widget.

  Widget render(Map<String, Screen> screensList) {
    if (!screensList.containsKey(this.layoutName)) {
      return NssErrorWidget.routeMissMatch();
    }

    final Screen screen = screensList[this.layoutName];

    if (screen.children.isNullOrEmpty()) {
      return NssErrorWidget.screenWithNotChildren();
    }

    final List<NssWidgetData> children = screen.children;

    return _build(screen, _renderWidgets(children));
  }

  List<Widget> _renderWidgets(List<NssWidgetData> listOfWidgets) {
    List<Widget> widgets = [];

    if (listOfWidgets.isEmpty) {
      return widgets;
    }

    listOfWidgets.forEach((widget) {
      bool isNotNull = widget.children != null ? true : false;

      if (isNotNull) {
        widgets.add(_renderByAlignment(widget.stack, _renderWidgets(widget.children)));
      } else {
        widgets.add(NssWidgetFactory().create(widget.type, widget));
      }
    });

    return widgets;
  }

  Widget _build(Screen screen, List<Widget> list) {
    return Scaffold(
        appBar: screen.appBar != null
            ? AppBar(
                title: Text(screen.appBar['textKey']),
              )
            : null,
        body: SafeArea(
          child: Container(
            child: _renderByAlignment(screen.stack, list),
          ),
        ));
  }

  // Render the list by alignment.
  Widget _renderByAlignment(NssAlignment alignment, List list) {
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

extension IterableExt on Iterable {
  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }
}
