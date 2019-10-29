import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TakePicture extends StatefulWidget {
  @override
  TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<TakePicture> {
  CameraController _controller;
  String lastPicture;
  List<CameraDescription> cameras;
  int cameraIndex;

  void initAsync() async {
    cameras = await availableCameras();
    cameraIndex = 0;
    onCameraSelected(cameras[0]);
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) await _controller.dispose();
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }
    if (mounted) setState(() {});
  }

  void nextCamera() {
    if (cameras.length == 0) {
      return;
    } else if (cameras.length - 1 == cameraIndex) {
      cameraIndex = 0;
    } else {
      cameraIndex++;
    }
    onCameraSelected(cameras[cameraIndex]);
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      backgroundColor: Colors.black,
      body: lastPicture == null
          ? _controller == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Container(
                    child: CameraPreview(_controller),
                  ),
                )
          : Center(
              child: Image.file(
                File(lastPicture),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        items: lastPicture == null
            ? [
                BottomNavigationBarItem(
                  title: Text(''),
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  title: new Text(''),
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.camera_rear,
                      color: Colors.white,
                    ),
                  ),
                ),
              ]
            : [
                BottomNavigationBarItem(
                  title: Text(''),
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  title: new Text(''),
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
        onTap: (index) async {
          if (lastPicture == null) {
            if (index == 0) {
              try {
                lastPicture = join(
                  (await getTemporaryDirectory()).path,
                  '${DateTime.now()}.png',
                );
                await _controller.takePicture(lastPicture);
                setState(() {});
              } catch (e) {
                print(e);
              }
            } else if (index == 1) {
              nextCamera();
            }
          } else {
            if (index == 0) {
              Navigator.pop(
                context,
                lastPicture,
              );
            } else if (index == 1) {
              lastPicture = null;
              setState(() {});
            }
          }
        },
      ),
    );
  }
}
