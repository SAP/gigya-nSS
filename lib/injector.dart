import 'package:flutter/foundation.dart';
import 'package:gigya_native_screensets_engine/comm/communications.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/router.dart';
import 'package:gigya_native_screensets_engine/startup.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/services/api_service.dart';
import 'package:gigya_native_screensets_engine/services/screen_service.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:ioc/ioc.dart';

/// Wrapping an Ioc container package to avoid hard coupling the nss dependency injection.
class NssIoc {
  static NssIoc _ioc;

  factory NssIoc() {
    if (_ioc is NssIoc) {
      return _ioc;
    }

    _ioc = new NssIoc._();

    return _ioc;
  }

  static NssIoc create() {
    return new NssIoc._();
  }

  NssIoc._();

  /// Currently using the Ioc dart pub at (https://pub.dev/packages/ioc#-readme-tab-).
  final container = Ioc();

  NssIoc register<T>(dynamic carrier, T builder(Ioc ioc), {bool singleton, bool lazy}) {
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
  void startEngine({bool asMock = false}) {
    NssIoc()
        .register(NssConfig, (ioc) => NssConfig(isMock: asMock), singleton: true)
        .register(NssChannels, (ioc) => !kIsWeb ? MobileChannels() : WebChannels.instance().channels, singleton: true)
        .register(BindingModel, (ioc) => BindingModel())
        .register(Logger, (ioc) => Logger(ioc.use(NssConfig), ioc.use(NssChannels)))
        .register(MaterialWidgetFactory, (ioc) => MaterialWidgetFactory())
        .register(CupertinoWidgetFactory, (ioc) => CupertinoWidgetFactory())
        .register(
          MaterialRouter,
          (ioc) => MaterialRouter(
            ioc.use(NssConfig),
            ioc.use(NssChannels),
            ioc.use(MaterialWidgetFactory),
          ),
        )
        .register(
          CupertinoRouter,
          (ioc) => CupertinoRouter(
            ioc.use(NssConfig),
            ioc.use(NssChannels),
            ioc.use(CupertinoWidgetFactory),
          ),
        )
        .register(ApiService, (ioc) => ApiService(ioc.use(NssChannels)))
        .register(ScreenService, (ioc) => ScreenService(ioc.use(NssChannels)))
        .register(ScreenViewModel, (ioc) => ScreenViewModel(ioc.use(ApiService), ioc.use(ScreenService)))
        .register(
            StartupWidget,
            (ioc) => StartupWidget(
                  config: ioc.use(NssConfig),
                  channels: ioc.use(NssChannels),
                ),
            singleton: true);
  }
}
