import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vplayer/component/custom_video_player.dart';
import 'package:vplayer/const/color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: video == null ? renderEmpty() : renderVideo(),
    );
  }

  Widget renderEmpty() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [firstColor, secondColor]),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_Logo(onTap: newVideoTap), const _AppName()],
      ),
    );
  }

  Widget renderVideo() {
    return Center(
      child: CustomVideoPlayer(
        video: video!,
        onNewVideoPressed: newVideoTap,
      ),
    );
  }

  void newVideoTap() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        this.video = video;
      });
    }
  }
}

class _AppName extends StatelessWidget {
  const _AppName();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.w300, fontSize: 30.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "VIDEO",
          style: textStyle,
        ),
        Text("PLAYER", style: textStyle.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  final VoidCallback onTap;
  const _Logo({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap, child: Image.asset('asset/image/logo.png'));
  }
}
