import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

class PutObjectPage extends StatefulWidget {
  const PutObjectPage({super.key});

  @override
  State<PutObjectPage> createState() => _PutObjectPageState();
}

class _PutObjectPageState extends State<PutObjectPage> {
  late String filePath;
  File? file;

  handleUpdate() async {
    getIt.get<COSClient>().putObject(
        filePath: filePath,
        bucket: 'erp-client-temp-test-1301114422',
        key: '/ic_launcher.png');
  }

  handleUpdateByteArray() async {
    final byteArr = file!.readAsBytesSync();
    getIt.get<COSClient>().putObject(
        byteArr: byteArr,
        bucket: 'erp-client-temp-test-1301114422',
        key: '/ic_launcher.png',
        headers: {
          'Content-Type': 'image/png',
        });
  }

  init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    filePath = '${appDocDir.path}/ic_launcher.png';
    file = await getIt.get<COSClient>().getObject(
          savePath: filePath,
          bucket: 'erp-client-temp-test-1301114422',
          key: '/ic_launcher.png',
        );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        file != null
            ? Center(child: Image.file(file!, width: 200, height: 200))
            : const SizedBox(),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: handleUpdate,
                child: const Text('上传(filePath)'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: handleUpdateByteArray,
                child: const Text('上传(ByteArray)'),
              ),
            ],
          ),
        )
      ],
    );
  }
}
