import 'package:gigya_native_screensets_engine/models/markup.dart';

class NssConfig {
  String version = '1.9.1';
  bool? isMock = false;
  bool isPlatformAware = false;
  String? platformAwareMode = 'material';
  Markup? markup;
  Map<dynamic, dynamic>? schema;

  NssConfig({this.isMock, required this.isPlatformAware, this.markup});
}
