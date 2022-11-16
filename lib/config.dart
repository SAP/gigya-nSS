import 'package:gigya_native_screensets_engine/comm/moblie_channel.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';

class NssConfig {
  String version = '1.6.0';
  bool? isMock = false;
  bool? isPlatformAware = false;
  Markup? markup;
  Map<dynamic, dynamic>? schema;

  NssConfig({this.isMock, this.isPlatformAware, this.markup});
}

class NssChannels {
  final NssChannel ignitionChannel;
  final NssChannel screenChannel;
  final NssChannel apiChannel;
  final NssChannel logChannel;
  final NssChannel dataChannel;
  final NssChannel eventsChannel;

  NssChannels(
    this.ignitionChannel,
    this.screenChannel,
    this.apiChannel,
    this.logChannel,
    this.dataChannel,
    this.eventsChannel,
  );
}
