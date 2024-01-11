import 'dart:async';
import 'dart:io';
import 'package:tencent_cos_sdk_chassis/chassis/utils/cos_logger.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

extension COSGutObject on COSClient {
  /// 下载对象
  /// 参考文档： https://cloud.tencent.com/document/product/436/7749
  /// [savePath] 文件下载路径
  /// [progress] 下载进度
  Future<File?> getObject({
    required String savePath,
    required String bucket,
    required String key,
    void Function(int downloadedBytes, int totalBytes)? progress,
    String? region,
    Map<String, String>? headers,
    Map<String, String>? params,
  }) async {
    COSLogger.t('getObject: begin');

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

            if (res != null) {
              if (res.statusCode == HttpStatus.ok) {
                final totalBytes = res.contentLength;
                int downloadedBytes = 0;

                COSLogger.t('getObject: totalBytes: $totalBytes');
                COSLogger.t(
                    'getObject: contentType: ${res.headers.contentType}');

                File file = File(savePath);

                if (!file.existsSync()) {
                  await file.create(recursive: true);
                }

                final sink = file.openWrite();

                await res.map((chunk) {
                  downloadedBytes += chunk.length;

                  COSLogger.t('$downloadedBytes / $totalBytes');

                  if (progress != null) {
                    progress(downloadedBytes, totalBytes);
                  }

                  return chunk;
                }).pipe(sink);

                return file;
              } else {
                throw await COSException.fromResponse(res);
              }
            } else {
              throw Exception('getObject: res is null');
            }
          },
          (context, data) async {
            COSLogger.t('getObject: end');

            return Future.value(data);
          }
        ]));
  }
}
