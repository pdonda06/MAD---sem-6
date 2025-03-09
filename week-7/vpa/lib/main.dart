import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'V P A',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  void _initializeController(VideoPlayerController controller) {
    _controller?.dispose(); // Dispose previous controller
    _controller = controller;
    _initializeVideoPlayerFuture = _controller!.initialize();
    _controller!.setLooping(true);
    setState(() {});
    _controller!.play();
  }

  void _loadNetworkVideo() {
    _initializeController(VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    ));
  }

  void _loadAssetVideo() {
    _initializeController(VideoPlayerController.asset('../assets/sample.mp4'));
  }

  Future<void> _loadLocalVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      if (kIsWeb) {
        Uint8List bytes = result.files.single.bytes!;
        String videoUri = Uri.dataFromBytes(bytes, mimeType: 'video/mp4').toString();
        _initializeController(VideoPlayerController.networkUrl(Uri.parse(videoUri)));
      } else {
        File file = File(result.files.single.path!);
        _initializeController(VideoPlayerController.file(file));
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _seekForward() {
    _controller?.seekTo(_controller!.value.position + const Duration(seconds: 10));
  }

  void _seekBackward() {
    _controller?.seekTo(_controller!.value.position - const Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Video Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_controller != null)
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          const SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: _loadNetworkVideo,
                  child: const Text("Load Network Video")),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: _loadAssetVideo,
                  child: const Text("Load Asset Video")),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: _loadLocalVideo,
                  child: const Text("Load Local Video")),
            ],
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            onPressed: _seekBackward,
            child: const Icon(Icons.replay_10, color: Colors.white),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            onPressed: () {
              setState(() {
                if (_controller != null && _controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller?.play();
                }
              });
            },
            child: Icon(
              _controller?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            onPressed: _seekForward,
            child: const Icon(Icons.forward_10, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
