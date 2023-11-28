import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final VoidCallback onNewVideoPressed;

  const CustomVideoPlayer(
      {super.key, required this.video, required this.onNewVideoPressed});
  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController;
  Duration currentPosition = const Duration(seconds: 0);
  bool showControls = false;

  @override
  void initState() {
    super.initState();
    initiateVideoController();
  }

  void initiateVideoController() async {
    currentPosition = const Duration(seconds: 0);
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
      videoController!.dispose();
      initiateVideoController();
      videoController!.addListener(() {
        final currentPosition = videoController!.value.position;
        setState(() {
          this.currentPosition = currentPosition;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    videoController!.dispose();
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
                    onRewindPressed: onRewindPressed,
                    onPlayPressed: onPlayPressed,
                    onForwardPressed: onForwardPressed,
                    isPlaying: videoController!.value.isPlaying),
              if (showControls)
                _NewVideo(
                  onPressed: onNewVideoPressed,
                ),
              _BottomSlider(
                currentPosition: currentPosition,
                maxPosition: videoController!.value.duration,
                onChanged: onSliderChanged,
              )
            ],
          ),
        ));
  }

  void onRewindPressed() {
    final Duration currentPosition = videoController!.value.position;
    Duration newPosition = const Duration();
    if (currentPosition > const Duration(seconds: 3)) {
      newPosition = currentPosition - const Duration(seconds: 3);
    }
    videoController!.seekTo(newPosition);
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
    Duration newPosition = maxPosition;
    if (currentPosition < maxPosition - const Duration(seconds: 3)) {
      newPosition = currentPosition + const Duration(seconds: 3);
    }
    videoController!.seekTo(newPosition);
  }

  void onNewVideoPressed() {
    widget.onNewVideoPressed();
  }

  void onSliderChanged(double value) {
    setState(() {
      Duration newPosition = Duration(seconds: value.toInt());
      videoController!.seekTo(newPosition);
    });
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onForwardPressed;
  final VoidCallback onRewindPressed;
  final VoidCallback onPlayPressed;
  final bool isPlaying;

  const _Controls({
    super.key,
    required this.onForwardPressed,
    required this.onRewindPressed,
    required this.onPlayPressed,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
            onPressed: onRewindPressed,
            icon: Icons.fast_rewind,
          ),
          renderIconButton(
            onPressed: onPlayPressed,
            icon: isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          renderIconButton(
            onPressed: onForwardPressed,
            icon: Icons.fast_forward,
          ),
        ],
      ),
    );
  }

  IconButton renderIconButton(
      {required VoidCallback? onPressed, required IconData icon}) {
    return IconButton(
        onPressed: onPressed,
        iconSize: 30,
        icon: Icon(
          icon,
          color: Colors.white,
        ));
  }
}

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewVideo({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: IconButton(
          onPressed: onPressed,
          iconSize: 30,
          color: Colors.white,
          icon: const Icon(Icons.photo_camera_back)),
    );
  }
}

class _BottomSlider extends StatelessWidget {
  final ValueChanged<double> onChanged;
  final Duration currentPosition;
  final Duration maxPosition;
  const _BottomSlider({
    super.key,
    required this.onChanged,
    required this.currentPosition,
    required this.maxPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      left: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Text(
              '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: Slider(
                  max: maxPosition.inSeconds.toDouble(),
                  min: 0,
                  value: currentPosition.inSeconds.toDouble(),
                  onChanged: onChanged),
            ),
            Text(
              '${maxPosition.inMinutes}:${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
