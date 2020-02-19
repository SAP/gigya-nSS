/// Extension for [Iterable] instance. Null or empty check.
extension IterableExt on Iterable {
  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }
}

extension StringExt on String {
  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }
}

/// Extension for [Map] !containsKey
extension MapExt<T, V> on Map<T, V> {
  bool unavailable(T key) {
    return !this.containsKey(key);
  }
}
