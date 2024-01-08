import 'package:tencent_cos_sdk_chassis/chassis/cos_config.dart';
import 'package:tencent_cos_sdk_chassis/chassis/fetch/cos_fetch.dart';
import 'package:tencent_cos_sdk_chassis/chassis/fetch/cos_fetch_config.dart';
import 'package:tencent_cos_sdk_chassis/chassis/utils/memory_cache.dart';

class COSClient {
  final COSConfig config;

  /// 请求实例，一般情况下使用 send 方法，
  /// 如有特殊逻辑可使用 fetch 对象
  COSFetch fetch = COSFetch();

  /// 缓存工具实例
  MemoryCache memoryCache = MemoryCache();

  /// COS 客户端
  /// [config] 全局配置
  COSClient({required this.config});

  /// 发送请求
  /// [fetchConfig] 请求配置
  Future<T> send<T>(COSFetchConfig fetchConfig) {
    return fetch.send<T>(fetchConfig, config);
  }
}
