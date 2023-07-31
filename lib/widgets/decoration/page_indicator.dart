import 'dart:math';

import 'package:flutter/material.dart';

/// Animated indicator showing the current selected page.
class PageIndicator extends AnimatedWidget {
  PageIndicator({
    required this.controller,
    this.itemCount,
    this.color: Colors.white,
  }) : super(listenable: controller);

  final PageController controller;
  final int? itemCount;

  /// Default color is white if none specified and is attached to fontColor property.
  /// Will fallback to "enabledColor" theme property.
  final Color? color;

  static const double _ovalSize = 4.0;
  static const double _maxZoom = 2.0;
  static const double _spacing = 18.0;

  Widget _buildIndocator(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_maxZoom - 1.0) * selectedness;
    return new Container(
      width: _spacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: _ovalSize * zoom,
            height: _ovalSize * zoom,
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount!, _buildIndocator),
    );
  }
}
