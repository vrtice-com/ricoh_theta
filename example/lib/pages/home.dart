import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ricoh_theta/models/image_infoes.dart';
import 'package:ricoh_theta/ricoh_theta.dart';
import 'package:ricoh_theta_example/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ricohThetaPlugin = RicohTheta();
  List<ImageInfoes> _imageInfoes = [];
  double _livePreviewFPS = 15.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricoh Theta Plugin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: Stack(
              children: [
                StreamBuilder<Uint8List>(
                  stream: _ricohThetaPlugin.listenCameraImages(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return Stack(
                        children: [
                          Center(
                            child: Image.memory(
                              snapshot.data!,
                              gaplessPlayback: true,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _ricohThetaPlugin.resumeLiveView();
                                  },
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _ricohThetaPlugin.pauseLiveView();
                                  },
                                  icon: const Icon(
                                    Icons.pause_circle,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _ricohThetaPlugin.stopLiveView();
                                  },
                                  icon: const Icon(
                                    Icons.stop_circle,
                                  ),
                                ),
                                Text(
                                  'FPS: ${_livePreviewFPS.round()}',
                                  style: const TextStyle(
                                    backgroundColor: Colors.green,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                          child: ElevatedButton(
                        onPressed: () {
                          _ricohThetaPlugin.startLiveView(
                            fps: _livePreviewFPS,
                          );
                        },
                        child: const Text('Start Live'),
                      ));
                    }
                  },
                ),
              ],
            ),
          ),
          Column(
            children: [
              Slider.adaptive(
                min: 1,
                max: 60,
                divisions: 60,
                label: _livePreviewFPS.round().toString(),
                value: _livePreviewFPS,
                onChanged: (value) {
                  setState(() {
                    _livePreviewFPS = value;
                  });
                  _ricohThetaPlugin.adjustLiveViewFps(_livePreviewFPS);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Directory appDocDir =
                          await getApplicationDocumentsDirectory();
                      final takenPhotoInfo =
                          await _ricohThetaPlugin.takePicture(appDocDir.path);
                      if (takenPhotoInfo == null) {
                        return;
                      }

                      await showResultDialog(
                        context,
                        child: Image.file(
                          File('${appDocDir.path}/${takenPhotoInfo.fileName}'),
                        ),
                      );

                      getImages();
                    },
                    child: const Text('Take picture'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      getImages();
                    },
                    child: const Text('Refresh files'),
                  ),
                ],
              ),
            ],
          ),
          Flexible(
            child: ListView.builder(
              itemCount: _imageInfoes.length,
              itemBuilder: (context, index) {
                final ImageInfoes imageInfoes = _imageInfoes[index];
                return ListTile(
                  title: Text(imageInfoes.fileName),
                  subtitle: Text(
                    '${imageInfoes.imagePixWidth} * ${imageInfoes.imagePixHeight}',
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/home/image-view',
                        arguments: {
                          'fileId': imageInfoes.fileId,
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  getImages() async {
    final images = await _ricohThetaPlugin.getImageInfoes();

    setState(() {
      _imageInfoes = images;
    });
  }
}
