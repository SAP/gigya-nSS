import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

import 'nss_test_extensions.dart';

class UsesMixin with StyleMixin {}

void main() {
  group('Style mixing tests', () {
    NssIoc().register(NssConfig, (ioc) => NssConfig(isPlatformAware: true), singleton: true);
    NssIoc().use(NssConfig).isPlatformAware = false;

    var mixin = UsesMixin();

    test('ensureDouble() method', () {
      expect(mixin.ensureDouble(0), 0.0);
      expect(mixin.ensureDouble(1), 1.0);
      expect(mixin.ensureDouble(0.1), 0.1);
    });

    test('withPadding() method', () {
      expect(mixin.getPadding(2), EdgeInsets.all(2.0));
      expect(mixin.getPadding(2.0), EdgeInsets.all(2.0));
      expect(mixin.getPadding([1, 1, 1, 1]), EdgeInsets.all(1.0));
      expect(mixin.getPadding([2, 0.0, 1, 0.1]), EdgeInsets.only(left: 2.0, top: 0.0, right: 1.0, bottom: 0.1));
      expect(mixin.getPadding(''), EdgeInsets.all(0));
    });

    test('getColor() method', () {
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

    Map<String, dynamic> dataStyle = {
      'margin': 22,
      'fontSize': 16,
      'fontColor': 'black',
      'fontWeight': 8,
      'background': 'red',
      'elevation': 7,
      'opacity': 2.0,
      'borderColor': 'green',
      'borderSize': 3,
      'cornerRadius': 3
    };

    Map<String, dynamic> mockStyle;

    NssIoc().use(NssConfig).markup = Markup(screens: {});

    test('test getting style', () {
      mockStyle = dataStyle;

      expect(mixin.getStyle(Styles.margin, styles: mockStyle), EdgeInsets.all(22.0));
      expect(mixin.getStyle(Styles.fontSize, styles: mockStyle), 16.0);
      expect(mixin.getStyle(Styles.fontWeight, styles: mockStyle), FontWeight.w800);
      expect(mixin.getStyle(Styles.background, styles: mockStyle), Colors.red);
      expect(mixin.getStyle(Styles.elevation, styles: mockStyle), 7);
      expect(mixin.getStyle(Styles.opacity, styles: mockStyle), 2.0);
      expect(mixin.getStyle(Styles.borderColor, styles: mockStyle), Colors.green);
      expect(mixin.getStyle(Styles.borderSize, styles: mockStyle), 3.0);
      expect(mixin.getStyle(Styles.cornerRadius, styles: mockStyle), 3.0);
    });

    test('test getting default style', () {
      mockStyle = {};
      expect(mixin.getStyle(Styles.margin, styles: mockStyle), EdgeInsets.all(16.0));
      expect(mixin.getStyle(Styles.fontSize, styles: mockStyle), 14.0);
      expect(mixin.getStyle(Styles.fontWeight, styles: mockStyle), FontWeight.w400);
      expect(mixin.getStyle(Styles.background, styles: mockStyle), Colors.transparent);
      expect(mixin.getStyle(Styles.elevation, styles: mockStyle), 3);
      expect(mixin.getStyle(Styles.opacity, styles: mockStyle), 1.0);
      expect(mixin.getStyle(Styles.borderColor, styles: mockStyle), Colors.black);
      expect(mixin.getStyle(Styles.borderSize, styles: mockStyle), 1.0);
      expect(mixin.getStyle(Styles.cornerRadius, styles: mockStyle), 0.0);
    });

    test('test theme without data and with style', () {
      mockStyle = {};
      NssIoc().use(NssConfig).markup = Markup(
        screens: {},
        theme: {'primaryColor': 'red', 'secondaryColor': 'white'},
      );

      expect(mixin.getStyle(Styles.fontColor, styles: mockStyle), Colors.red);
      expect(mixin.getStyle(Styles.background, styles: mockStyle), Colors.white);
      expect(mixin.getStyle(Styles.borderColor, styles: mockStyle), Colors.red);
    });

    test('test theme without data and style', () {
      mockStyle = {};
      NssIoc().use(NssConfig).markup = Markup(screens: {}, theme: {});

      expect(mixin.getStyle(Styles.fontColor, styles: mockStyle), Colors.black);
      expect(mixin.getStyle(Styles.background, styles: mockStyle), Colors.transparent);
      expect(mixin.getStyle(Styles.borderColor, styles: mockStyle), Colors.black);
    });

    test('test theme with data and style', () {
      mockStyle = dataStyle;

      NssIoc().use(NssConfig).markup = Markup(
        screens: {},
        theme: {'primaryColor': 'red', 'secondaryColor': 'white'},
      );

      expect(mixin.getStyle(Styles.fontColor, styles: mockStyle), Colors.black);
      expect(mixin.getStyle(Styles.background, styles: mockStyle), Colors.red);
      expect(mixin.getStyle(Styles.borderColor, styles: mockStyle), Colors.green);
    });
  });
}
