import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

class DeleteObjectPage extends StatefulWidget {
  const DeleteObjectPage({super.key});

  @override
  State<DeleteObjectPage> createState() => _DeleteObjectPageState();
}

class _DeleteObjectPageState extends State<DeleteObjectPage> {
  handleDelete() {
    getIt.get<COSClient>().deleteObject(
        bucket: 'erp-client-temp-test-1301114422',
        key: '/app/00e905dc-70ce-4742-af58-da79cc34a24e');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: handleDelete,
            child: const Text('删除'),
          ),
        )
      ],
    );
  }
}
