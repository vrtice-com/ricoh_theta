import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ricoh_theta/models/ricoh_image.dart';
import 'package:ricoh_theta/ricoh_theta.dart';

class ImageViewPage extends StatefulWidget {
  final String fileId;
  const ImageViewPage({
    Key? key,
    required this.fileId,
  }) : super(key: key);

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  late Directory appDocDir;
  final _ricohThetaPlugin = RicohTheta();
  RicohImage? _image;

  @override
  void initState() {
    super.initState();

    loadImage();
    getApplicationDocumentsDirectory().then((value) {
      setState(() {
        appDocDir = value;
      });
    });
  }

  void loadImage() async {
    final image =
        await _ricohThetaPlugin.getImage(widget.fileId, appDocDir.path);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image preview'),
      ),
      body: SizedBox.expand(
        child: StreamBuilder(
          stream: _ricohThetaPlugin.listenDownloadProgress(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              final progress = snapshot.data as double;
              return _image == null
                  ? Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${(progress * 100).toStringAsFixed(0)}%'),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progress,
                          ),
                        ],
                      ),
                    )
                  : InteractiveViewer(
                      maxScale: 20,
                      child: Image.file(
                          File('${appDocDir.path}/${_image!.fileName}')),
                    );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
