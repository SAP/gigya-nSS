import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:test/test.dart';

class UsesMixin with WidgetDecorationMixin {}

void main() {
  group('NssWidgetDecorationMixin tests', () {
    var mixin = UsesMixin();
  });
}
