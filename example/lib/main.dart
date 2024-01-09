import 'package:example/pages/delete_object_page.dart';
import 'package:example/pages/get_object_page.dart';
import 'package:example/pages/get_object_url_page.dart';
import 'package:example/pages/pub_object_page.dart';
import 'package:example/proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:tencent_cos_sdk_chassis/tencent_cos_sdk_chassis.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'dev.env');

  getIt.registerSingleton<COSClient>(COSClient(
      config: COSConfig(
          secretId: dotenv.get('secretId'),
          secretKey: dotenv.get('secretKey'),
          appid: dotenv.get('appid'),
          region: dotenv.get('region'),
          scheme: 'http')));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tencent COS Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Tencent COS Plus'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  handleToPage(Widget component) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: component,
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    MyProxy.startProxy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.image_outlined),
                Text(' 获取链接测试'),
              ],
            ),
            onTap: () => handleToPage(const GetObjectUrlPage()),
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.delete_forever_outlined),
                Text(' 删除对象测试'),
              ],
            ),
            onTap: () => handleToPage(const DeleteObjectPage()),
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.download_done_outlined),
                Text(' 下载对象测试'),
              ],
            ),
            onTap: () => handleToPage(const GetObjectPage()),
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.upload_file_outlined),
                Text(' 上传对象测试'),
              ],
            ),
            onTap: () => handleToPage(const PutObjectPage()),
          ),
        ],
      ),
    );
  }
}
