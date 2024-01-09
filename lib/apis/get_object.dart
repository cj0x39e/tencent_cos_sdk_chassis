import 'dart:async';
import 'dart:io';

import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

extension COSGutObject on COSClient {
  /// 下载对象
  /// 参考文档： https://cloud.tencent.com/document/product/436/7749
  /// [savePath] 文件下载路径
  Future<File?> getObject({
    required String savePath,
    required String bucket,
    required String key,
    String? region,
    Map<String, String>? headers,
    Map<String, String>? params,
  }) async {
    return send<File?>(COSFetchConfig(
        bucket: bucket,
        key: key,
        method: 'GET',
        region: region,
        headers: headers,
        params: params,
        resHandlers: [
          (fetchContext, data) async {
            final res = fetchContext.res;
            final File file = File(savePath);
            await res?.pipe(file.openWrite());

            return file;
          }
        ]));
  }
}