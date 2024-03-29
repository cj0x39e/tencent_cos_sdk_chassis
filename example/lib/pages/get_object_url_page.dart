import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

class GetObjectUrlPage extends StatefulWidget {
  const GetObjectUrlPage({super.key});

  @override
  State<GetObjectUrlPage> createState() => _GetObjectUrlPageState();
}

class _GetObjectUrlPageState extends State<GetObjectUrlPage> {
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
