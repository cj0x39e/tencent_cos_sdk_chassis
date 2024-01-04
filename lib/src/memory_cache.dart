class MemoryCache {
  /// The maximum size of the cache, the default value is 200.
  final int maxCacheSize;

  MemoryCache({this.maxCacheSize = 200});

  List<String> orderList = [];

  Map<String, ({String value, int expired})> store = {};

  _removeOldest() {
    final key = orderList.removeAt(0);
    store.remove(key);
  }

  _removeByKey(String key) {
    orderList.remove(key);
    store.remove(key);
  }

  /// Get a value from the memory.
  /// if the key is not in the memory or the value is expired will return a null value.
  /// [key] The key.
  String? getValue(String key) {
    final info = store[key];

    if (info == null) {
      return null;
    } else {
      final (value: value, expired: expired) = info;

      if (expired > DateTime.now().millisecondsSinceEpoch) {
        return value;
      } else {
        _removeByKey(key);
        return null;
      }
    }
  }

  /// Adding a value to the memory with an expired time.
  /// [key] The key.
  /// [value] The value.
  /// [expired] The expired time. The unit is ms since 1970.
  void addValue(String key, String value, int expired) {
    if (orderList.length >= maxCacheSize) {
      _removeOldest();
    }

    orderList.add(key);

    store[key] = (value: value, expired: expired);
  }
}
