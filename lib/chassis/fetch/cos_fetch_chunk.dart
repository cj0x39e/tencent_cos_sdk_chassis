enum COSFetchChunkStatus {
  none,

  inputting,

  inputFinished,

  outputting,

  outputFinished,
}

class COSFetchChunk {
  /// 在文件中起始位置
  final int start;

  /// 在文件中结束位置
  final int end;

  COSFetchChunkStatus _status = COSFetchChunkStatus.none;

  /// 文件处理状态
  COSFetchChunkStatus get status {
    return _status;
  }

  set status(COSFetchChunkStatus status) {
    if (status == COSFetchChunkStatus.outputFinished) {
      data = null;
    }

    _status = status;
  }

  /// chunk 的容量
  int get capacity {
    return end - start + 1;
  }

  /// 数据长度
  int get length {
    return data?.length ?? 0;
  }

  bool get isFull {
    return length == capacity;
  }

  List<int>? data;

  COSFetchChunk({
    required this.start,
    required this.end,
  });

  setData(List<int> bytes) {
    data = bytes;
  }
}
