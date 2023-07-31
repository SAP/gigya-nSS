import 'package:gigya_native_screensets_engine/comm/mobile_channel.dart';

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
