import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

class GetObjectPage extends StatefulWidget {
  const GetObjectPage({super.key});

  @override
  State<GetObjectPage> createState() => _GetObjectPageState();
}

class _GetObjectPageState extends State<GetObjectPage> {
  File? file;

  init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/ic_launcher.png';
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
    return file != null
        ? Center(child: Image.file(file!, width: 200, height: 200))
        : const SizedBox();
  }
}
