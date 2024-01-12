import 'dart:async';
import 'dart:io';
import 'package:tencent_cos_sdk_chassis/chassis/fetch/cos_fetch_chunk.dart';
import 'package:tencent_cos_sdk_chassis/chassis/fetch/cos_fetch_concurrent.dart';
import 'package:tencent_cos_sdk_chassis/chassis/utils/cos_logger.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

extension COSGutObject on COSClient {
  /// 下载对象
  /// 参考文档： https://cloud.tencent.com/document/product/436/7749
  /// [savePath] 文件下载路径
  /// [progress] 下载进度
  /// [concurrent] 同时发起请求数，默认 10
  /// [chunkSize] 下载分块大小，单位字节，默认 4M
  Future<File?> getObject({
    required String savePath,
    required String bucket,
    required String key,
    void Function(int downloadedBytes, int totalBytes)? progress,
    String? region,
    Map<String, String>? headers,
    Map<String, String>? params,
    int? chunkSize,
    int? concurrent,
  }) async {
    COSLogger.t('getObject: begin');

    File file = File(savePath);

    if (!file.existsSync()) {
      await file.create(recursive: true);
    }

    final randomAccessFile = await file.open(mode: FileMode.writeOnly);

    Future<int?> getContentLength() async {
      return send(COSFetchConfig(
          bucket: bucket,
          key: key,
          method: 'HEAD',
          region: region,
          headers: headers,
          params: params,
          resHandlers: [
            (fetchContext, data) async {
              final res = fetchContext.res;

              if (res != null) {
                if (res.statusCode == HttpStatus.ok) {
                  return res.headers.contentLength;
                } else {
                  throw await COSException.fromResponse(res);
                }
              } else {
                throw Exception('getObject: getContentLength: res is null');
              }
            },
            (context, data) async {
              COSLogger.t('getObject: getContentLength: end');

              return Future.value(data);
            }
          ]));
    }

    final totalSize = await getContentLength();
    int downloadedSize = 0;

    if (totalSize != null) {
      final fetchConcurrent = COSFetchConcurrent(
        chunkSize: chunkSize ?? 1024 * 1024 * 4,
        concurrent: concurrent ?? 10,
        totalSize: totalSize,
        input: (fetchChunk) async {
          await send(COSFetchConfig(
              bucket: bucket,
              key: key,
              method: 'GET',
              region: region,
              headers: {
                'Range': 'bytes=${fetchChunk.start}-${fetchChunk.end}',
                ...headers ?? {},
              },
              params: params,
              resHandlers: [
                (fetchContext, data) async {
                  final res = fetchContext.res;

                  if (res != null) {
                    if (res.statusCode == HttpStatus.partialContent) {
                      final controller = StreamController<List<int>>();

                      List<int> buffer = [];

                      controller.stream.listen((chunk) {
                        buffer.addAll(chunk);
                      });

                      await res.pipe(controller);

                      await controller.close();

                      fetchChunk.setData(buffer);

                      fetchChunk.status = COSFetchChunkStatus.inputFinished;

                      if (progress != null) {
                        downloadedSize += buffer.length;
                        progress(downloadedSize, totalSize);
                      }
                    } else {
                      throw await COSException.fromResponse(res);
                    }
                  } else {
                    throw Exception('getObject: res is null');
                  }

                  COSLogger.t('getObject: end');
                }
              ]));
        },
        output: (fetchChunk) async {
          await randomAccessFile.setPosition(fetchChunk.start);
          await randomAccessFile.writeFrom(fetchChunk.data!);

          fetchChunk.status = COSFetchChunkStatus.outputFinished;
        },
      );

      await fetchConcurrent.go();

      await randomAccessFile.close();

      return file;
    } else {
      throw Exception('getObject: getContentLength: totalSize is null');
    }
  }
}
