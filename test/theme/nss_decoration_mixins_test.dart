import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';

class UsesMixin with NssWidgetDecorationMixin {}

void main() {
  group('Testing decoration mixins', () {
    var mixin = UsesMixin();

    test('Testing ensureDouble() mehtod', () {
      expect(mixin.ensureDouble(0), 0.0);
      expect(mixin.ensureDouble(1), 1.0);
      expect(mixin.ensureDouble(0.1), 0.1);
    });

    test('Testing withPadding() method', () {
      expect(mixin.withPadding(2), EdgeInsets.all(2.0));
      expect(mixin.withPadding(2.0), EdgeInsets.all(2.0));
      expect(mixin.withPadding([1, 1, 1, 1]), EdgeInsets.all(1.0));
      expect(mixin.withPadding([2, 0.0, 1, 0.1]),
          EdgeInsets.only(left: 2.0, top: 0.0, right: 1.0, bottom: 0.1));
      expect(mixin.withPadding(''), EdgeInsets.all(0));
    });

    test('Testing getColor() method', () {
      // Named colors.
      expect(mixin.getColor('blue'), Colors.blue);
      expect(mixin.getColor('blue', platformAware: true), CupertinoColors.systemBlue);
      expect(mixin.getColor('red'), Colors.red);
      expect(mixin.getColor('red', platformAware: true), CupertinoColors.systemRed);
      expect(mixin.getColor('green'), Colors.green);
      expect(mixin.getColor('green', platformAware: true), CupertinoColors.systemGreen);
      expect(mixin.getColor('grey'), Colors.grey);
      expect(mixin.getColor('grey', platformAware: true), CupertinoColors.inactiveGray);
      expect(mixin.getColor('yellow'), Colors.yellow);
      expect(mixin.getColor('yellow', platformAware: true), CupertinoColors.systemYellow);
      expect(mixin.getColor('orange'), Colors.orange);
      expect(mixin.getColor('orange', platformAware: true), CupertinoColors.systemOrange);
      expect(mixin.getColor('white'), Colors.white);
      expect(mixin.getColor('white', platformAware: true), CupertinoColors.white);

      // Hex colors.
      expect(mixin.getColor('#c1c1c1'), Color(0xffc1c1c1));

      // Defaults
      expect(mixin.getColor(''), Colors.black);
      expect(mixin.getColor('', platformAware: true), CupertinoColors.black);
    });
  });
}
