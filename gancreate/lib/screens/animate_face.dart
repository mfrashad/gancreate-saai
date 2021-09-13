import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'dart:io';

class AnimateFace extends StatefulWidget {
  AnimateFace({Key? key}) : super(key: key);

  @override
  _AnimateFaceState createState() => _AnimateFaceState();
}

class _AnimateFaceState extends State<AnimateFace> {
  var dio = Dio();
  XFile?  _image;
  XFile? _video;
  String? _result;

  final picker = ImagePicker();

  VideoPlayerController? _videoPlayerController;
  VideoPlayerController? _resultVideoController;
  ChewieController? _chewieController;
  ChewieController? _resultChewieController;

  _pickImageFromGallery() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
        _image = image;    
    });
  }

  _pickVideo() async {
    _video = await picker.pickVideo(source: ImageSource.gallery);

    late VideoPlayerController controller;
    controller = kIsWeb? VideoPlayerController.network(_video!.path) :  VideoPlayerController.file(File(_video!.path));

    _videoPlayerController = controller
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
    );
  }

  _submit() async {
      var formData = FormData.fromMap({
      'files': [
        MultipartFile.fromBytes((await _image!.readAsBytes()), filename: _image!.name),
        MultipartFile.fromBytes((await _video!.readAsBytes()), filename: _video!.name),
      ]
    });
    print('Sending request...');
    Response<dynamic> response = await dio.post('http://94b591f025a8.ngrok.io/animate/face', data: formData, options: Options(responseType: ResponseType.bytes));
    
    print(response.statusCode);
    var responseBytes = response.data;
    final blob = html.Blob([responseBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    _result = url;
    _resultVideoController= VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });

    _resultChewieController = ChewieController(
      videoPlayerController: _resultVideoController!,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (_image != null)
                  Container(
                    child: kIsWeb? Image.network(_image!.path) : Image.file(File(_image!.path)),
                    height: 300
                  )
                else
                  Text(
                    "Click on Pick Image to select an Image",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ElevatedButton(
                  onPressed: () {
                    _pickImageFromGallery();
                  },
                  child: Text("Pick Image From Gallery"),
                ),
                SizedBox(
                  height: 16.0,
                ),
                if (_video != null)
                  Container(
                    child: _videoPlayerController!.value.isInitialized
                      ? Chewie(
                          controller: _chewieController!,
                        )
                        : Container(),
                    height: 300

                  )
                  
                else
                  Text(
                    "Click on Pick Video to select video",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ElevatedButton(
                  onPressed: () {
                    _pickVideo();
                  },
                  child: Text("Pick Video From Gallery"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _submit();
                  },
                  child: Text('Submit')
                ),
                if (_resultVideoController != null)
                  Container(
                    child: _resultVideoController!.value.isInitialized
                      ? Chewie(
                          controller: _resultChewieController!,
                        )
                        : Container(),
                    height: 300

                  )
              ],
            ),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    _chewieController!.dispose();
    super.dispose();
  }
}