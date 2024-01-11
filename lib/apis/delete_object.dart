import 'dart:io';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

extension COSDeleteObject on COSClient {
  /// 删除对象
  /// 参考文档： https://cloud.tencent.com/document/product/436/7743
  Future<void> deleteObject({
    required String bucket,
    required String key,
    String? region,
    Map<String, String>? headers,
    Map<String, String>? params,
  }) async {
    return send(COSFetchConfig(
        bucket: bucket,
        key: key,
        method: 'DELETE',
        region: region,
        headers: headers,
        params: params,
        resHandlers: [
          (fetchContext, data) async {
            final res = fetchContext.res;

            if (res?.statusCode != HttpStatus.noContent) {
              throw await COSException.fromResponse(res);
            }
          }
        ]));
  }
}
