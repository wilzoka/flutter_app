import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:dio/dio.dart';

class FileUploader extends StatefulWidget {
  final String filePath;

  const FileUploader({
    Key key,
    @required this.filePath,
  }) : super(key: key);

  @override
  FileUploaderState createState() => FileUploaderState();
}

class FileUploaderState extends State<FileUploader> {
  double percent = 0.0;
  Dio dio = Dio();
  String erro = '';
  CancelToken cancelToken = CancelToken();

  void initAsync() async {
    final filename = widget.filePath.split('/').last;
    FormData formData = FormData.fromMap(
      {
        "file": await MultipartFile.fromFile(
          widget.filePath,
          filename: filename,
        ),
      },
    );
    final response = await dio.post("${Utils.mainurl}/file",
        cancelToken: cancelToken,
        data: formData,
        options: Options(
          headers: {
            'x-access-token': Utils.jwt,
          },
        ), onSendProgress: (int sent, int total) {
      if (mounted)
        setState(() {
          percent = sent / total;
        });
    });
    if (response.statusCode == 200) {
      Navigator.pop(context, response.data['data']);
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
        title: Text('Upload de Arquivo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              erro.isEmpty ? 'Enviando... ${(percent*100).toInt()}%' : erro,
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
