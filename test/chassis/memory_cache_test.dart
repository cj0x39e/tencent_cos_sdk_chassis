import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_cos_sdk_chassis/chassis/utils/memory_cache.dart';

void main() {
  late MemoryCache memoryCache;
  setUp(() => {memoryCache = MemoryCache(maxCacheSize: 2)});

  test('normal add and get', () {
    memoryCache.addValue(
        'key', 'value', DateTime.now().millisecondsSinceEpoch + 1000 * 60);
    final v = memoryCache.getValue('key');
    expect(
      v,
      'value',
    );
  });

  test('should be null when the value is expired', () {
    memoryCache.addValue(
        'key', 'value', DateTime.now().millisecondsSinceEpoch + 1000 * 2);

    final v = memoryCache.getValue('key');
    expect(v, 'value');

    return Future.delayed(const Duration(seconds: 3)).then((value) {
      final v = memoryCache.getValue('key');
      expect(v, null);
    });
  });

  test('should be null when the key is not in the memory', () {
    final v = memoryCache.getValue('key-not-exist');
    expect(v, null);
  });

  test('the oldest value should be removed when the cache is full', () {
    memoryCache.addValue(
        'key1', 'value1', DateTime.now().millisecondsSinceEpoch + 1000 * 60);
    memoryCache.addValue(
        'key2', 'value2', DateTime.now().millisecondsSinceEpoch + 1000 * 60);
    memoryCache.addValue(
        'key3', 'value3', DateTime.now().millisecondsSinceEpoch + 1000 * 60);

    final v1 = memoryCache.getValue('key1');
    final v2 = memoryCache.getValue('key2');
    final v3 = memoryCache.getValue('key3');

    expect(v1, null);
    expect(v2, 'value2');
    expect(v3, 'value3');
  });
}
