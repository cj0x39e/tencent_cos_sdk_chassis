import 'dart:io';
import 'package:tencent_cos_sdk_chassis/chassis/utils/cos_logger.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

class COSFetch {
  /// 全局请求处理函数，在所有请求处理函数之前调用
  List<Future<void> Function(COSFetchContext fetchContext)> globalReqHandlers =
      [];

  /// 全局响应处理函数，在所有响应处理函数之前调用
  List<Future<dynamic> Function(COSFetchContext fetchContext, dynamic data)>
      globalResHandlers = [];

  COSFetch() {
    globalReqHandlers.add(reqAddingHeadersHandler);
    globalReqHandlers.add(reqAddingSignHandler);
  }

  /// 发送请求
  /// [fetchConfig] 请求相关配置
  /// [config] COS 相关配置
  Future<T> send<T>(COSFetchConfig fetchConfig, COSConfig config) async {
    try {
      HttpClient client = HttpClient();

      final fetchContext =
          COSFetchContext(fetchConfig: fetchConfig, config: config);

      final url = Uri.parse(fetchContext.url);
      final req = await client.openUrl(fetchConfig.method, url);

      COSLogger.t('${fetchConfig.method} ${url.toString()}');

      fetchContext.req = req;

      final reqHandles = [...globalReqHandlers, ...?fetchConfig.reqHandlers];

      try {
        for (final handler in reqHandles) {
          await handler(fetchContext);
        }
      } catch (error) {
        req.close();

        rethrow;
      }

      final res = await req.close();

      fetchContext.res = res;

      final resHandles = [...globalResHandlers, ...?fetchConfig.resHandlers];

      dynamic data;
      for (final handler in resHandles) {
        data = await handler(fetchContext, data);
      }

      return data;
    } catch (error) {
      if (error is SocketException && !fetchConfig.isRetryTimesExceed) {
        fetchConfig.increaseRetryTimes();
        return send(fetchConfig, config);
      } else {
        rethrow;
      }
    }
  }

  /// 添加请求头
  Future<void> reqAddingHeadersHandler(COSFetchContext fetchContext) async {
    fetchContext.fetchConfig.headers?.forEach((key, value) {
      fetchContext.req?.headers.add(key, value);
    });
  }

  /// 添加请求签名
  Future<void> reqAddingSignHandler(COSFetchContext fetchContext) async {
    fetchContext.req?.headers.add('Authorization', fetchContext.getSign());
  }
}
