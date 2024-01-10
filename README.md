# tencent_cos_sdk_chassis

[![Dart](https://github.com/cj0x39e/tencent_cos_sdk_chassis/actions/workflows/dart.yml/badge.svg)](https://github.com/cj0x39e/tencent_cos_sdk_chassis/actions/workflows/dart.yml)

易于扩展的腾讯云 COS Dart SDK。

## 使用

```dart
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

/// 初始化
final cosClient = COSClient(
        config: COSConfig(
          secretId: '',
          secretKey: '',
          appid: '',
          region: '',
        ),);

/// 使用 API
cosClient.getObject()

```

## 扩展 API

因为腾讯云 COS SDK 的 API 相当多，而目前我需要使用的并不多，所以该仓库已实现的 API 只有几个。不过得益于易于扩展的底层设计，
你可以方便的扩展自己需要的 API。

下图展示了基本的架构：

![disign](https://raw.githubusercontent.com/cj0x39e/tencent_cos_sdk_chassis/master/assets/design.png)

具体的实现方式请参考 `lib/apis` 目录下的文件，其都是通过 `extension` 实现的。

## 致谢

本仓库签名相关实现参考了 [tencent_cos](https://github.com/zhangruiyu/tencent_cos)
