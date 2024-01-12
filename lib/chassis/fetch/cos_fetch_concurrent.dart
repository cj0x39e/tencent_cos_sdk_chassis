import 'dart:async';
import 'package:tencent_cos_sdk_chassis/chassis/fetch/cos_fetch_chunk.dart';

class COSFetchConcurrent {
  /// chunk 大小，默认 4MB
  final int chunkSize;

  /// 并发数
  final int concurrent;

  /// 总的 byte 大小
  final int totalSize;

  final Future<void> Function(COSFetchChunk fetchChunk) input;

  final Future<void> Function(COSFetchChunk fetchChunk) output;

  COSFetchConcurrent({
    this.chunkSize = 1024 * 1024 * 4,
    this.concurrent = 10,
    required this.totalSize,
    required this.input,
    required this.output,
  });

  List<COSFetchChunk> chunks = [];
  int _pendingRequests = 0;
  int _offset = 0;
  bool _noRequests = false;
  bool _outputting = false;
  final Completer _completer = Completer();

  _output() async {
    if (_outputting) return;

    final chunkIndex = chunks.indexWhere(
        (chunk) => chunk.status == COSFetchChunkStatus.inputFinished);

    if (chunkIndex != -1) {
      COSFetchChunk fetchChunk = chunks[chunkIndex];

      fetchChunk.status = COSFetchChunkStatus.outputting;

      _outputting = true;

      await output(fetchChunk);

      _outputting = false;

      _output();
    } else {
      if (chunks.every(
          (chunk) => chunk.status == COSFetchChunkStatus.outputFinished)) {
        _completer.complete();
      }
    }
  }

  _input() {
    if (_noRequests) return;

    final max = concurrent - _pendingRequests;

    for (int i = 0; i < max; i++) {
      int end = _offset + chunkSize;
      final isLast = end >= totalSize;

      if (isLast) {
        _noRequests = true;
        end = totalSize;
      }

      final chunk = COSFetchChunk(start: _offset, end: end - 1);
      chunks.add(chunk);

      chunk.status = COSFetchChunkStatus.inputting;

      input(chunk).then((_) {
        _pendingRequests--;
        _input();
        _output();
      });

      _pendingRequests++;
      _offset = end;

      if (isLast) {
        break;
      }
    }
  }

  Future<void> go() async {
    _input();

    return _completer.future;
  }
}
