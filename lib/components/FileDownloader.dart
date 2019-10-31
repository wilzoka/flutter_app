import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FileDownloader extends StatefulWidget {
  final Map file;

  const FileDownloader({
    Key key,
    @required this.file,
  }) : super(key: key);

  @override
  FileDownloaderState createState() => FileDownloaderState();
}

class FileDownloaderState extends State<FileDownloader> {
  double percent = 0.0;
  Dio dio = Dio();
  String erro = '';
  CancelToken cancelToken = CancelToken();

  void initAsync() async {
    final response = await dio.get(
        '${Utils.mainurl}/file/${widget.file['id'].toString()}',
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            headers: {'x-access-token': Utils.jwt}),
        onReceiveProgress: (int sent, int total) {
      if (mounted)
        setState(() {
          percent = sent / total;
        });
    });
    if (response.statusCode == 200) {
      final savePath = (await getTemporaryDirectory()).path;
      final filePath = '$savePath/${widget.file['filename']}';
      File file = File(filePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      OpenFile.open(filePath);
      await raf.close();
      Navigator.pop(context);
    } else {}
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  void dispose() {
    if (!cancelToken.isCancelled) cancelToken.cancel("cancelled");
    dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download de Arquivo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              erro.isEmpty ? 'Baixando... ${(percent * 100).toInt()}%' : erro,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(value: percent),
          ],
        ),
      ),
    );
  }
}
