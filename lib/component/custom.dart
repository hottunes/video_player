import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer2 extends StatefulWidget {
  final XFile video;
  const CustomVideoPlayer2({super.key, required this.video});

  @override
  State<CustomVideoPlayer2> createState() => _CustomVideoPlayer2State();
}

class _CustomVideoPlayer2State extends State<CustomVideoPlayer2> {
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  void initializeController() async {
    videoController = VideoPlayerController.file(File(widget.video.path));
    await videoController!.initialize();
    setState(onPlayPressed);
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return const CircularProgressIndicator();
    }
    return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(videoController!),
            _Controls(
              onPlayPressed: onPlayPressed,
              onForwardPressed: onForwardPressed,
              onReversePressed: onReversePressed,
              isPlaying: videoController!.value.isPlaying,
            ),
            _NewVideo(
              onNewVideoPressed: onNewVideoPressed,
            )
          ],
        ));
  }

  void onReversePressed() {
    final currentPosition = videoController!.value.position;
    Duration position = const Duration();
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - const Duration(seconds: 3);
    }
    videoController!.seekTo(position);
  }

  void onForwardPressed() {
    final maxPosition = videoController!.value.duration;
    final currentPosition = videoController!.value.position;
    Duration position = maxPosition;
    if ((maxPosition - const Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + const Duration(seconds: 3);
    }
    videoController!.seekTo(position);
  }

  void onPlayPressed() {
    setState(() {
      videoController!.value.isPlaying
          ? videoController!.pause()
          : videoController!.play();
    });
  }

  void onNewVideoPressed() {}
}

class _NewVideo extends StatelessWidget {
  const _NewVideo({
    super.key,
    required this.onNewVideoPressed,
  });

  final VoidCallback onNewVideoPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: IconButton(
          onPressed: onNewVideoPressed,
          color: Colors.white,
          iconSize: 30.0,
          icon: const Icon(Icons.photo_camera_back)),
    );
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;

  const _Controls({
    required this.onPlayPressed,
    required this.onReversePressed,
    required this.onForwardPressed,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
              iconData: Icons.rotate_left, onPressed: onReversePressed),
          renderIconButton(
              iconData: isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: onPlayPressed),
          renderIconButton(
              iconData: Icons.rotate_right, onPressed: onForwardPressed),
        ],
      ),
    );
  }

  IconButton renderIconButton(
      {required VoidCallback onPressed, required IconData iconData}) {
    return IconButton(
        onPressed: onPressed,
        iconSize: 30,
        icon: Icon(
          iconData,
          color: Colors.white,
        ));
  }
}
