import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/ui/widget_factory.dart';

class NSSLayoutBuilder {
  final String layoutName;

  NSSLayoutBuilder(this.layoutName);

  // The render method should be render the json to one Widget.

  Widget render(Map<String, Screen> screensList) {
    if(!screensList.containsKey(this.layoutName)) {
      return Container();
    }

    Screen screen = screensList[this.layoutName];

    if(screen.children.isEmpty) {
      return Container();
    }

    List<NSSWidget> listOfWidgets = screen.children;

    List<Widget> widgets = _renderWidgets(listOfWidgets);

    if(screen.appBar.isNotEmpty) {
      return _renderWithAppBar(screen, widgets);
    }

    return _renderByAlignment(screen.stack, widgets);
  }

  List<Widget> _renderWidgets(List<NSSWidget> listOfWidgets) {
    List<Widget> widgets = [];

    if(listOfWidgets.isNotEmpty) {
      listOfWidgets.forEach((widget) {
        bool isNotNull = widget.children ?? false;

        if(isNotNull) {
          widgets.add(_renderByAlignment(widget.stack, _renderWidgets(widget.children)));
        } else {
          widgets.add(SoleWidgetFactory().create(widget.type, widget));
        }
      });
    }

    return widgets;
  }

  // Render the widget with AppBar (Only in screen).
  Widget _renderWithAppBar(Screen screen, List<Widget> list) {
    return Scaffold(
        appBar: AppBar(
          title: Text(screen.appBar['textKey']),
        ),
        body: Container(
          child: _renderByAlignment(screen.stack, list),
        )
    );
  }


  // Render the list by alignment.
  Widget _renderByAlignment(String alignment, List list) {
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