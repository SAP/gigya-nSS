import 'package:gigya_native_screensets_engine/models/markup.dart';

class NssConfig {
  bool isMock = false;
  bool isPlatformAware = false;
  Markup markup;
  Map<dynamic, dynamic> schema;

  NssConfig({this.isMock, this.isPlatformAware, this.markup});
}

class NssChannels {
  final dynamic ignitionChannel;
  final dynamic screenChannel;
  final dynamic apiChannel;
  final dynamic logChannel;
  final dynamic dataChannel;
  final dynamic eventsChannel;

  NssChannels(this.ignitionChannel, this.screenChannel, this.apiChannel, this.logChannel, this.dataChannel, this.eventsChannel);
}
