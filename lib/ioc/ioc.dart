class Ioc {
  static Ioc? iocInstance;

  Map<String, dynamic> config = {'singleton': false, 'lazy': false};

  Map _bindingMap = new Map();

  Map _singletonMap = new Map();

  List _lazyLoadSingletonList = [];

  factory Ioc() {
    if (iocInstance != null) {
      return iocInstance!;
    }

    iocInstance = new Ioc._();

    return iocInstance!;
  }

  static Ioc create() {
    return new Ioc._();
  }

  Ioc._();

  Ioc bind<T>(dynamic carrier, T builder(Ioc ioc), {bool? singleton, bool? lazy}) {
    bool shouldUseSingleton = config['singlton'] == true || singleton == true;
    bool shouldLazyLoadSingleton = config['lazy'] == true || lazy == true;

    if (shouldUseSingleton && shouldLazyLoadSingleton) {
      _addLazySingleton(carrier, builder);

      return this;
    }

    if (shouldUseSingleton) {
      _bindSingleton(carrier, builder);

      return this;
    }

    _bind(carrier, builder);

    return this;
  }

  T? use<T>(dynamic carrier) {
    if (_isLazyLoadSingleton(carrier)) {
      _bindSingleton(carrier, _bindingMap[carrier]);
      _removeLazySingleton(carrier);
    }

    var singleton = _singletonMap[carrier];

    if (singleton != null) {
      return singleton;
    }

    var binding = _bindingMap[carrier];

    if (binding != null) {
      return binding(this);
    }

    return null;
  }

  bool _isLazyLoadSingleton(dynamic carrier) {
    return _lazyLoadSingletonList.contains(carrier);
  }

  void _addLazySingleton<T>(dynamic carrier, T builder) {
    _bindingMap[carrier] = builder;
    _lazyLoadSingletonList.add(carrier);
  }

  void _removeLazySingleton<T>(dynamic carrier) {
    _bindingMap.remove(carrier);
    _lazyLoadSingletonList.remove(carrier);
  }

  void _bindSingleton<T>(dynamic carrier, T builder(Ioc ioc)) {
    _singletonMap[carrier] = builder(this);
  }

  void _bind<T>(dynamic carrier, T builder(Ioc ioc)) {
    _bindingMap[carrier] = builder;
  }
}