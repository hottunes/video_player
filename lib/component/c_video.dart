import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final VoidCallback onNewVideoPressed;
  final XFile video;
  const CustomVideoPlayer(
      {super.key, required this.video, required this.onNewVideoPressed});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController;
  Duration currentPosition = const Duration();
  bool showControls = false;

  @override
  void initState() {
    super.initState();
    initializeVideoController();
  }

  void initializeVideoController() async {
    currentPosition = const Duration();
    videoController = VideoPlayerController.file(File(widget.video.path));
    await videoController!.initialize();
    videoController!.addListener(() {
      final currentPosition = videoController!.value.position;
      setState(() {
        this.currentPosition = currentPosition;
      });
    });
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.path != widget.video.path) {
      initializeVideoController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return const CircularProgressIndicator();
    }
    return AspectRatio(
      aspectRatio: videoController!.value.aspectRatio,
      child: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack(
          children: [
            VideoPlayer(videoController!),
            if (showControls)
              _Controls(
                onReversePressed: onReversedPressed,
                onForwardPressed: onForwardPressed,
                onPlayPressed: onPlayPressed,
                isPlaying: videoController!.value.isPlaying,
              ),
            if (showControls) _NewVideo(onPressed: widget.onNewVideoPressed),
            _SliderBottom(
              currentPosition: currentPosition,
              maxPosition: videoController!.value.duration,
              onChanged: onSliderChanged,
            ),
          ],
        ),
      ),
    );
  }

  void onReversedPressed() {
    final Duration currentPosition = videoController!.value.position;
    Duration position = const Duration();
    if (currentPosition > const Duration(seconds: 3)) {
      position = currentPosition - const Duration(seconds: 3);
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

  void onForwardPressed() {
    final Duration currentPosition = videoController!.value.position;
    Duration maxPosition = videoController!.value.duration;
    Duration position = const Duration();

    if (maxPosition - const Duration(seconds: 3) > currentPosition) {
      position = currentPosition + const Duration(seconds: 3);
    }
    videoController!.seekTo(position);
  }

  void onSliderChanged(double value) {
    setState(() {
      Duration position = Duration(seconds: value.toInt());
      videoController!.seekTo(position);
    });
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onReversePressed;
  final VoidCallback onPlayPressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;
  const _Controls({
    required this.onReversePressed,
    required this.onPlayPressed,
    required this.onForwardPressed,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      height: MediaQuery.of(context).size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
              onPressed: onReversePressed, iconData: Icons.fast_rewind),
          renderIconButton(
              onPressed: onPlayPressed,
              iconData: isPlaying ? Icons.pause : Icons.play_arrow),
          renderIconButton(
              onPressed: onForwardPressed, iconData: Icons.fast_forward),
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

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewVideo({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: IconButton(
          onPressed: onPressed,
          iconSize: 30,
          icon: const Icon(
            Icons.photo_camera_back,
            color: Colors.white,
          )),
    );
  }
}

class _SliderBottom extends StatelessWidget {
  const _SliderBottom({
    required this.currentPosition,
    required this.onChanged,
    required this.maxPosition,
  });

  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
                '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white)),
            Expanded(
                child: Slider(
                    max: maxPosition.inSeconds.toDouble(),
                    min: 0,
                    value: currentPosition.inSeconds.toDouble(),
                    onChanged: onChanged)),
            Text(
                '${maxPosition.inMinutes}:${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white))
          ],
        ),
      ),
    );
  }
}
