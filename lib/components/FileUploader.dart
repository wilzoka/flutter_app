import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

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
  final uploader = FlutterUploader();

  void initAsync() async {
    print('initasync');
    List savedDir = widget.filePath.split('/');
    final filename = savedDir[savedDir.length - 1];
    savedDir.removeLast();
    final taskId = await uploader.enqueue(
        url: Utils.mainurl + '/file',
        files: [
          FileItem(
              filename: filename,
              savedDir: savedDir.join('/'),
              fieldname: "file")
        ],
        method: UploadMethod.POST,
        headers: {"token": await Utils.getPreference('token')},
        showNotification: true,
        tag: "upload 1");
    print('task $taskId');
  }

  @override
  void initState() {
    super.initState();

    uploader.progress.listen((progress) {
      print(progress);
    });
    uploader.result.listen((result) {
      print(
          "id: ${result.taskId}, status: ${result.status}, response: ${result.response}, statusCode: ${result.statusCode}, tag: ${result.tag}, headers: ${result.headers}");

      // // final task = _tasks[result.tag];
      // if (task == null) return;

      // setState(() {
      //   _tasks[result.tag] = task.copyWith(status: result.status);
      // });
    }, onError: (ex, stacktrace) {
      print("exception: $ex");
      print("stacktrace: $stacktrace" ?? "no stacktrace");
      // UploadException exp = ex as UploadException;
      // final task = _tasks[exp.tag];
      // if (task == null) return;

      // setState(() {
      //   _tasks[exp.tag] = task.copyWith(status: exp.status);
      // });
    });

    initAsync();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arquivos'),
      ),
      body: Container(
        child: Text('asd'),
      ),
    );
  }
}
