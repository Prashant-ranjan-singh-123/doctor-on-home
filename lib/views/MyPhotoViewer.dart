import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MyPhotoViewer extends StatefulWidget {
  final String url;
  MyPhotoViewer({Key? key, required this.url}) : super(key: key);
  @override
  State<MyPhotoViewer> createState() => _MyPhotoViewerState();
}

class _MyPhotoViewerState extends State<MyPhotoViewer> {
  GlobalKey<FormState> _sKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return  Hero(
        tag: widget.url,
        child: PhotoView(
          key: _sKey,
          imageProvider: CachedNetworkImageProvider(
          widget.url,
        ),
          maxScale: 1.0,
          minScale: 0.2,
        ),
    );
  }
}
