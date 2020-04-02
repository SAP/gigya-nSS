import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:gigya_native_screensets_engine/nss_router.dart';
import 'package:gigya_native_screensets_engine/services/nss_api_service.dart';
import 'package:gigya_native_screensets_engine/services/nss_screen_service.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:ioc/ioc.dart';

/// Wrapping an Ioc container package to avoid hard coupling the nss dependency injection.
class NssInjector {
  static NssInjector _injector;

  factory NssInjector() {
    if (_injector is NssInjector) {
      return _injector;
    }

    _injector = new NssInjector._();

    return _injector;
  }

  static NssInjector create() {
    return new NssInjector._();
  }

  NssInjector._();

  /// Currently using the Ioc dart pub at (https://pub.dev/packages/ioc#-readme-tab-).
  final container = Ioc();

  NssInjector register<T>(dynamic carrier, T builder(Ioc ioc), {bool singleton, bool lazy}) {
    container.bind(
      carrier,
      builder,
      singleton: singleton,
      lazy: lazy,
    );
    return this;
  }

  T use<T>(dynamic carrier) {
    return container.use<T>(carrier);
  }
}

class NssContainer {
  NssIgnitionWidget startEngine({bool asMock = false}) {
    NssInjector()
        .register(NssConfig, (ioc) => NssConfig(isMock: asMock), singleton: true)
        .register(NssChannels, (ioc) => NssChannels(), singleton: true);
    NssInjector().register(
      NssLogger,
      (ioc) {
        NssChannels channels = ioc.use(NssChannels);
        return NssLogger(channels: channels);
      },
    ).register(
      NssWidgetFactory,
      (ioc) {
        NssConfig config = ioc.use(NssConfig);
        NssChannels channels = ioc.use(NssChannels);
        return NssWidgetFactory(
          config: config,
          channels: channels,
        );
      },
    ).register(
      ApiService,
      (ioc) {
        NssChannels channels = ioc.use(NssChannels);
        return ApiService(channels: channels);
      },
    ).register(
      ScreenService,
      (ioc) {
        NssChannels channels = ioc.use(NssChannels);
        return ScreenService(channels: channels);
      },
    ).register(
      NssScreenViewModel,
      (ioc) {
        ApiService apiService = ioc.use(ApiService);
        ScreenService screenService = ioc.use(ScreenService);
        return NssScreenViewModel(apiService, screenService);
      },
    ).register(
      Router,
      (ioc) {
        NssConfig config = ioc.use(NssConfig);
        NssChannels channels = ioc.use(NssChannels);
        NssWidgetFactory factory = ioc.use(NssWidgetFactory);
        return Router(config: config, channels: channels, widgetFactory: factory);
      },
    ).register(
      IgnitionWorker,
      (ioc) {
        NssConfig config = ioc.use(NssConfig);
        NssChannels channels = ioc.use(NssChannels);
        return IgnitionWorker(config: config, channels: channels);
      },
    ).register(
      NssIgnitionWidget,
      (ioc) {
        NssConfig config = ioc.use(NssConfig);
        IgnitionWorker iw = ioc.use(IgnitionWorker);
        NssChannels channels = ioc.use(NssChannels);
        Router router = ioc.use(Router);
        return NssIgnitionWidget(
          worker: iw,
          config: config,
          channels: channels,
          router: router,
        );
      },
    );

    // Return ignition.
    return NssInjector().use(NssIgnitionWidget);
  }
}
