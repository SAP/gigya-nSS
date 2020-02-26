import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_app.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_factory.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:gigya_native_screensets_engine/nss_router.dart';
import 'package:gigya_native_screensets_engine/services/nss_api_service.dart';
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
  void register() {
    NssInjector()
        .register(NssConfig, (ioc) => NssConfig(isMock: true), singleton: true)
        .register(NssChannels, (ioc) => NssChannels(), singleton: true)
        .register(ApiService, (ioc) => ApiService());
    NssInjector().register(NssWidgetFactory, (ioc) {
      NssConfig config = ioc.use(NssConfig);
      NssChannels channels = ioc.use(NssChannels);
      return NssWidgetFactory(
        config: config,
        channels: channels,
      );
    }).register(
      NssScreenViewModel,
      (ioc) {
        ApiService api = ioc.use(ApiService);
        return NssScreenViewModel(api);
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
        return IgnitionWorker(config);
      },
    ).register(
      NssIgnitionWidget,
      (ioc) {
        NssConfig config = ioc.use(NssConfig);
        IgnitionWorker iw = ioc.use(IgnitionWorker);
        Router router = ioc.use(Router);
        return NssIgnitionWidget(
          worker: iw,
          config: config,
          router: router,
        );
      },
    );
  }
}
