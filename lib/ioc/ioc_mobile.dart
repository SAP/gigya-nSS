import 'package:gigya_native_screensets_engine/comm/mobile_channel.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/services/api_service.dart';
import 'package:gigya_native_screensets_engine/services/screen_service.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';

import '../config.dart';

class MobileContainer {
  void startEngine({bool asMock = false}) {
    NssIoc()
        .register(NssConfig, (ioc) => NssConfig(isMock: asMock),
            singleton: true)
        .register(NssChannels, (ioc) => MobileChannels(), singleton: true)
        .register(BindingModel, (ioc) => BindingModel())
        .register(RuntimeStateEvaluator, (ioc) => RuntimeStateEvaluator())
        .register(
            Logger, (ioc) => Logger(ioc.use(NssConfig), ioc.use(NssChannels)))
        .register(WidgetCreationFactory, (ioc) => WidgetCreationFactory())
        .register(CupertinoWidgetFactory, (ioc) => CupertinoWidgetFactory())
        .register(
            PlatformRouter,
            (ioc) => PlatformRouter(ioc.use(NssConfig), ioc.use(NssChannels),
                ioc.use(WidgetCreationFactory)))
        .register(ApiService, (ioc) => ApiService(ioc.use(NssChannels)))
        .register(ScreenService, (ioc) => ScreenService(ioc.use(NssChannels)))
        .register(
            ScreenViewModel,
            (ioc) =>
                ScreenViewModel(ioc.use(ApiService), ioc.use(ScreenService)));
  }
}
