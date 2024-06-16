import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoThumbNail extends StatefulWidget {

  String url;


  MyVideoThumbNail(this.url);

  @override
  _MyVideoThumbNailState createState() => _MyVideoThumbNailState();
}

class _MyVideoThumbNailState extends State<MyVideoThumbNail> {

  late VideoPlayerController _videoPlayerController1;

  Future<void> initializePlayer() async {
    _videoPlayerController1 = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _videoPlayerController1.initialize();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController1.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: VideoPlayer(_videoPlayerController1),
    );
  }
}
