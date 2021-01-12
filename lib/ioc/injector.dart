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
