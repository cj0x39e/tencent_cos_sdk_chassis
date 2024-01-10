import 'dart:io';

import 'package:mime/mime.dart';
import 'package:tencent_cos_sdk_chassis/chassis/utils/cos_logger.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

extension COSPutObject on COSClient {
  /// 上传对象
  /// 参考文档： https://cloud.tencent.com/document/product/436/7749
  /// [filePath] 文件路径
  Future<void> putObject({
    required String filePath,
    required String bucket,
    required String key,
    String? region,
    Map<String, String>? headers,
    Map<String, String>? params,
  }) async {
    COSLogger.t('putObject: begin');

    return send(COSFetchConfig(
        bucket: bucket,
        key: key,
        method: 'PUT',
        region: region,
        headers: headers,
        params: params,
        reqHandlers: [
          (COSFetchContext context) async {
            final req = context.req;

            final mime = lookupMimeType(filePath);
            final file = File(filePath);
            final fileLength = file.lengthSync();
            final fs = file.openRead();

            req?.headers
                .add('Content-Type', mime ?? 'application/octet-stream');
            req?.headers.add('Content-Length', fileLength);

            await req?.addStream(fs);
          }
        ],
        resHandlers: [
          (fetchContext, data) async {
            final res = fetchContext.res;

            if (res?.statusCode != HttpStatus.ok) {
              throw COSException(res: res);
            }

            COSLogger.t('putObject: end');
          }
        ]));
  }
}
