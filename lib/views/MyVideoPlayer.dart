// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
//
// class MyVideoPlayer extends StatefulWidget {
//   String url;
//
//   MyVideoPlayer(this.url);
//
//   @override
//   _MyVideoPlayerState createState() => _MyVideoPlayerState();
// }
//
// class _MyVideoPlayerState extends State<MyVideoPlayer> {
//
//   TargetPlatform? _platform;
//   VideoPlayerController? _videoPlayerController1;
//   ChewieController? _chewieController;
//
//   @override
//   void initState() {
//     super.initState();
//     this.initializePlayer();
//   }
//
//   @override
//   void dispose() {
//     _videoPlayerController1!.dispose();
//     _chewieController!.dispose();
//     super.dispose();
//   }
//
//   Future<void> initializePlayer() async {
//     _videoPlayerController1 = VideoPlayerController.network(widget.url);
//     await _videoPlayerController1!.initialize();
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController1,
//       autoPlay: false,
//       looping: true,
//       // Try playing around with some of these other options:
//
//       // showControls: false,
//       // materialProgressColors: ChewieProgressColors(
//       //   playedColor: Colors.red,
//       //   handleColor: Colors.blue,
//       //   backgroundColor: Colors.grey,
//       //   bufferedColor: Colors.lightGreen,
//       // ),
//       // placeholder: Container(
//       //   color: Colors.grey,
//       // ),
//       // autoInitialize: true,
//     );
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: Center(
//               child: _chewieController != null &&
//                   _chewieController!
//                       .videoPlayerController.value.initialized
//                   ? Chewie(
//                 controller: _chewieController,
//               )
//                   : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 20),
//                   Text('Loading...'),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

class MyVideoPlayer extends StatefulWidget {
  final String url;
  final int type;

  MyVideoPlayer({Key? key, required this.url, required this.type})
      : super(key: key);

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;

  Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(context)
        .loadString('assets/bumble_bee_captions.vtt');
    return WebVTTCaptionFile(
        fileContents); // For vtt files, use WebVTTCaptionFile
  }

  @override
  void initState() {
    super.initState();
    print("widget.url ${widget.url}");
    print("widget.type ${widget.type}");
    _controller = (widget.type == 1)
        ? VideoPlayerController.file(
            File(widget.url),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
        : VideoPlayerController.networkUrl(
            Uri.parse(widget.url),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BLACK,
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      width: MediaQuery.of(context).size.width,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: false,
                        colors: VideoProgressColors(
                            backgroundColor: Colors.blueGrey,
                            bufferedColor: Colors.blueGrey,
                            playedColor: Colors.blueAccent),
                      ))
                ],
              )
            : Container(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
      ),
      floatingActionButton: Container(
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }
}
