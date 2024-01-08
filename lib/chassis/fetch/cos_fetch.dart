import 'dart:convert';
import 'dart:io';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';
import 'package:xml/xml.dart';

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
    globalResHandlers.add(resStatusCodeHandler);
  }

  /// 发送请求
  /// [fetchConfig] 请求相关配置
  /// [config] COS 相关配置
  Future<T> send<T>(COSFetchConfig fetchConfig, COSConfig config) async {
    HttpClient client = HttpClient();

    final fetchContext =
        COSFetchContext(fetchConfig: fetchConfig, config: config);

    final req =
        await client.openUrl(fetchConfig.method, Uri.parse(fetchContext.url));

    final reqHandles = [...globalReqHandlers, ...?fetchConfig.reqHandlers];

    for (final handler in reqHandles) {
      await handler(fetchContext);
    }

    final res = await req.close();

    fetchContext.res = res;

    final resHandles = [...globalResHandlers, ...?fetchConfig.resHandlers];

    dynamic data;
    for (final handler in resHandles) {
      data = await handler(fetchContext, data);
    }

    return data;
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

  /// 响应码处理
  Future<dynamic> resStatusCodeHandler(
      COSFetchContext fetchContext, dynamic data) async {
    final res = fetchContext.res;
    String? content = await res?.transform(utf8.decoder).join("");

    if (res?.statusCode != 200 || res?.statusCode != 204) {
      throw COSException(res!.statusCode, content ?? '');
    } else {
      if (res?.statusCode == 200) {
        return XmlDocument.parse(content!);
      }
    }
  }
}
