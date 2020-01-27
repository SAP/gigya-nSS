import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/ui/widget_factory.dart';

class LayoutBuilder {
  final String layoutName;

  LayoutBuilder(this.layoutName);

  // The render method should be render the json to one Widget.

  Widget render(Screen screen) {
    if(screen.children.isEmpty) {
      return Container();
    }

    List<NSSWidget> listOfWidgets = screen.children;

    List<Widget> widgets = renderWidgets(listOfWidgets);

    if(screen.appBar.isNotEmpty) {
      return renderWithAppBar(screen.appBar, widgets);
    }

    return renderByAlignment(screen.stack, widgets);
  }

  List<Widget> renderWidgets(List<NSSWidget> listOfWidgets) {
    List<Widget> widgets = [];

    if(listOfWidgets.isNotEmpty) {
      listOfWidgets.forEach((widget) {
        if(widget.children.isNotEmpty) {
          widgets.add(renderByAlignment(widget.stack, renderWidgets(widget.children)));
        } else {
          widgets.add(SoleWidgetFactory().create(widget.type, widget));
        }
      });
    }

    return widgets;
  }

  Widget renderWithAppBar(Map<String, dynamic> map, List<Widget> list) {
    return Scaffold(
        appBar: AppBar(
          title: map["textKey"],
        ),
        body: Container(
          child: renderByAlignment(map["stack"], list),
        )
    );
  }


  // Render the array by alignment.
  Widget renderByAlignment(String alignment, List list) {
    switch(alignment) {
      case "vertical":
        return Column(children: list);
      case "horizontal":
        return Row(children: list);
      default:
        return Column(children: list);
    }
  }
}