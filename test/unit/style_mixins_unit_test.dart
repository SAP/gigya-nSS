import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

import 'nss_test_extensions.dart';

class UsesMixin with StyleMixin {}

void main() {
  group('Style mixing tests', (){

    NssIoc().register(NssConfig, (ioc) => NssConfig(isPlatformAware: true), singleton: true);
    NssIoc().use(NssConfig).isPlatformAware = false;

    var mixin = UsesMixin();

    Map<String, dynamic> dataStyle = {
      'margin': 22,
      'fontSize': 16,
      'fontColor': 'black',
      'fontWeight': 8,
      'background': 'red',
      'elevation': 7,
      'opacity': 2.0,
      "borderColor": "green",
      "borderSize": 3,
      "cornerRadius": 3
    };

    Map<String, dynamic> mockStyle;

    NssIoc().use(NssConfig).markup = Markup(screens: {});

    test("test getting style", (){
       mockStyle = dataStyle;

      expect(mixin.getStyle(Styles.margin, mockStyle), EdgeInsets.all(22.0));
      expect(mixin.getStyle(Styles.fontSize, mockStyle), 16.0);
      expect(mixin.getStyle(Styles.fontWeight, mockStyle), FontWeight.w800);
      expect(mixin.getStyle(Styles.background, mockStyle), Colors.red);
      expect(mixin.getStyle(Styles.elevation, mockStyle), 7);
      expect(mixin.getStyle(Styles.opacity, mockStyle), 2.0);
      expect(mixin.getStyle(Styles.borderColor, mockStyle), Colors.green);
      expect(mixin.getStyle(Styles.borderSize, mockStyle), 3.0);
      expect(mixin.getStyle(Styles.cornerRadius, mockStyle), 3.0);
    });

    test("test getting default style", (){
      mockStyle = {};
      expect(mixin.getStyle(Styles.margin, mockStyle), EdgeInsets.all(16.0));
      expect(mixin.getStyle(Styles.fontSize, mockStyle), 14.0);
      expect(mixin.getStyle(Styles.fontWeight, mockStyle), FontWeight.w400);
      expect(mixin.getStyle(Styles.background, mockStyle), Colors.transparent);
      expect(mixin.getStyle(Styles.elevation, mockStyle), 3);
      expect(mixin.getStyle(Styles.opacity, mockStyle), 1.0);
      expect(mixin.getStyle(Styles.borderColor, mockStyle), Colors.black);
      expect(mixin.getStyle(Styles.borderSize, mockStyle), 1.0);
      expect(mixin.getStyle(Styles.cornerRadius, mockStyle), 0.0);
    });

    test("test theme without data and with style", (){
      mockStyle = {};
      NssIoc().use(NssConfig).markup = Markup(screens: {}, theme: {"primaryColor": "red", "secondaryColor": "white"});

      expect(mixin.getStyle(Styles.fontColor, mockStyle), Colors.red);
      expect(mixin.getStyle(Styles.background, mockStyle), Colors.white);
      expect(mixin.getStyle(Styles.borderColor, mockStyle), Colors.red);
    });

    test("test theme without data and style", (){
      mockStyle = {};
      NssIoc().use(NssConfig).markup = Markup(screens: {}, theme: {});

      expect(mixin.getStyle(Styles.fontColor, mockStyle), Colors.black);
      expect(mixin.getStyle(Styles.background, mockStyle), Colors.transparent);
      expect(mixin.getStyle(Styles.borderColor, mockStyle), Colors.black);
    });

    test("test theme with data and style", (){
      mockStyle = dataStyle;

      NssIoc().use(NssConfig).markup = Markup(screens: {}, theme: {"primaryColor": "red", "secondaryColor": "white"});

      expect(mixin.getStyle(Styles.fontColor, mockStyle), Colors.black);
      expect(mixin.getStyle(Styles.background, mockStyle), Colors.red);
      expect(mixin.getStyle(Styles.borderColor, mockStyle), Colors.green);
    });
  });
}