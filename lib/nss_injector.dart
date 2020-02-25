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

  NssInjector register<T>(dynamic carrier, T builder(NssInjector inj), {bool singleton, bool lazy}) {
    container.bind(
      carrier,
      (container) {
        return builder;
      },
      singleton: singleton,
      lazy: lazy,
    );
    return this;
  }

  T get<T>(dynamic carrier) {
    return container.use(carrier);
  }
}
