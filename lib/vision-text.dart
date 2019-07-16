import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mlkit/mlkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class VisionTextWidget extends StatefulWidget {
  @override
  _VisionTextWidgetState createState() => _VisionTextWidgetState();
}

class _VisionTextWidgetState extends State<VisionTextWidget> {
  File _file;
  List<VisionText> _currentLabels = <VisionText>[];

  FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Text Detection'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: ocr,
          child: Icon(Icons.camera),
        ),
      ),
    );
  }

  void ocr() async {
    try {
      // var file = await ImagePicker.pickImage(source: ImageSource.gallery);
      var file = await ImagePicker.pickImage(source: ImageSource.camera);
      var file1 = await ImageCropper.cropImage(
        sourcePath: file.path,
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
      );
      if (file1 != null) {
        setState(() {
          _file = file1;
        });
        try {
          var currentLabels = await detector.detectFromPath(_file?.path);
          setState(() {
            _currentLabels = currentLabels;
          });
        } catch (e) {
          print(e.toString());
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          _buildImage(),
          _buildList(_currentLabels),
        ],
      ),
    );
  }

   Widget _buildImage() {
    return SizedBox(
      height: 300.0,
      child: Center(
        child: _file == null
            ? Text('No Image')
            : FutureBuilder<Size>(
                future: _getImageSize(Image.file(_file, fit: BoxFit.fitWidth)),
                builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        foregroundDecoration:
                            TextDetectDecoration(_currentLabels, snapshot.data),
                        child: Image.file(_file, fit: BoxFit.fitWidth));
                  } else {
                    return Text('Detecting...');
                  }
                },
              ),
      ),
    );
  }

  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()))));
    return completer.future;
  }

  Widget _buildList(List<VisionText> texts) {
    if (texts.length == 0) {
      return Text('Empty');
    }
    List<VisionTextLine> liness = <VisionTextLine>[];

    for (VisionTextBlock block in texts) {
      for (VisionTextLine line in block.lines){
        liness.add(line);
      }
    }

    return Expanded(
      child: Container(
        child: ListView.builder(
            padding: const EdgeInsets.all(0.5),
            itemCount: liness.length,
            itemBuilder: (context, i) {
              return _buildRow(liness[i].text);
            }),
      ),
    );
  }

  Widget _buildRow(String text) {
    TextEditingController _controller = TextEditingController();
    // _controller.text = '$text';
    return TextField(
      controller: _controller
      ..text = '$text'
      ..selection = TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: text.length,
        ),
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
      ),
      maxLines: 1,
    );
  }
}

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionText> _texts;
  TextDetectDecoration(List<VisionText> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _TextDetectPainter(_texts, _originalImageSize);
  }
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionText> _texts;
  final Size _originalImageSize;
  _TextDetectPainter(texts, originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    print("original Image Size : $_originalImageSize");

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var text in _texts) {
      print("text : $text.text, rect : $text.rect");
      final _rect = Rect.fromLTRB(
          offset.dx + text.rect.left / _widthRatio,
          offset.dy + text.rect.top / _heightRatio,
          offset.dx + text.rect.right / _widthRatio,
          offset.dy + text.rect.bottom / _heightRatio);

      print("_rect : $_rect");
      canvas.drawRect(_rect, paint);
    }

    print("offset : $offset");
    print("configuration : $configuration");

    final rect = offset & configuration.size;

    print("rect container : $rect");

    //canvas.drawRect(rect, paint);
    canvas.restore();
  }
}
