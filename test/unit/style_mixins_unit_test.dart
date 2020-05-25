import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

class UsesMixin with StyleMixin {}

void main() {
  group('Style mixing tests', (){

    NssIoc().register(NssConfig, (ioc) => NssConfig(isMock: true), singleton: true);
    NssIoc().use(NssConfig).isPlatformAware = false;

    var mixin = UsesMixin();

    Map<String, dynamic> mockStyle = {
      'padding': 22,
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

    test("test getting style", (){
      expect(mixin.getStyle(Styles.padding, mockStyle), EdgeInsets.all(22.0));
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
      expect(mixin.getStyle(Styles.padding, mockStyle), EdgeInsets.all(16.0));
      expect(mixin.getStyle(Styles.fontSize, mockStyle), 14.0);
      expect(mixin.getStyle(Styles.fontWeight, mockStyle), FontWeight.w400);
      expect(mixin.getStyle(Styles.background, mockStyle), Colors.transparent);
      expect(mixin.getStyle(Styles.elevation, mockStyle), 3);
      expect(mixin.getStyle(Styles.opacity, mockStyle), 1.0);
      expect(mixin.getStyle(Styles.borderColor, mockStyle), Colors.black);
      expect(mixin.getStyle(Styles.borderSize, mockStyle), 1.0);
      expect(mixin.getStyle(Styles.cornerRadius, mockStyle), 0.0);
    });
  });
}