import 'package:gigya_native_screensets_engine/models/markup.dart';

class NssConfig {
  String version = '1.9.6';
  bool? isMock = false;
  bool isPlatformAware = false;
  String? platformAwareMode = 'material';
  Markup? markup;
  Markup? markupBackup;
  Map<dynamic, dynamic>? schema;

  // Specific style related data holders.
  Map<dynamic, dynamic> styleLibrary = {};
  Map<dynamic, dynamic> styleLibraryDefaults = {};

  NssConfig({this.isMock, required this.isPlatformAware, this.markup});
}
