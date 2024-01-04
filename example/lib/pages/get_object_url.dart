import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cos_plus/tencent_cos_plus.dart';

class GetObjectUrl extends StatefulWidget {
  const GetObjectUrl({super.key});

  @override
  State<GetObjectUrl> createState() => _GetObjectUrlState();
}

class _GetObjectUrlState extends State<GetObjectUrl> {
  @override
  Widget build(BuildContext context) {
    final url = getIt.get<COSClient>().getObjectUrl(
        bucket: 'erp-client-temp-test-1301114422',
        key: '/ic_launcher.png',
        sign: true);

    return Center(
        child: Image.network(
      url,
      width: 200,
    ));
  }
}
