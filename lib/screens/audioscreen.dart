import 'dart:io';
import 'package:audioapp/models/songsmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AudioScreen extends StatefulWidget {
  final Song song;
  //final void Function(Song song) onToggleFavorite;

  const AudioScreen({Key? key, required this.song,}) : super(key: key);

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {

  //var collection = FirebaseFirestore.instance.collection("user");
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  //late void Function(Song song) onToggleFavorite;

  Duration position = Duration.zero;
  late AudioCache audioCache;
  String audios = "";
  String images = "";
  late String downloadUrl;
  late String fileName;
  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  int downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    FlutterDownloader.initialize();
    
    audioPlayer = AudioPlayer();
    audioCache = AudioCache();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });

    fetchAudios();

    // Register a callback to monitor download progress
    FlutterDownloader.registerCallback((id, status, progress) {
       if (id == downloadUrl) {
        if (mounted) {
          setState(() {
            downloadProgress = progress.toInt();
          });
        }
      }
    });
  }

  Future<void> fetchAudios() async {
    try {
      print(widget.song.id);
      final response = await http.get(
          Uri.parse('https://jiosavvan.vercel.app/songs?id=${widget.song.id}'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData);
        if (jsonData.containsKey('data')) {
          print("success");

          List<dynamic> audiosData = jsonData['data'][0]['downloadUrl'];
          List<dynamic> imagesData = jsonData['data'][0]['image'];
          print(audiosData);
          print(imagesData);

          // Fetching the last URL
          String lastUrl = audiosData.last['link']; // Accessing the last URL
          String lastimage = imagesData.last['link'];
          print("hello sir");
          print(lastUrl);
          print("HAi");
          print(lastimage);

          setState(() {
            audios = lastUrl; // Storing the fetched audio in the list
            images = lastimage;
          });
        } else {
          print('No audio data found in API response');
        }
      } else {
        print('Failed to fetch audio. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching audio: $e');
    }
  }

 Future<void> downloadMedia(String url) async {
  try {
    // Request permission to access storage
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to access storage')),
      );
      return;
    }
     Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      // Handle if external storage directory is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External storage directory not available')),
      );
      return;
    }

    // Get the downloads directory

    // Create a Dio instance for making HTTP requests
    final dio = Dio();

    // Define the file path where the media will be downloaded
    final filePath = '${externalDir.path}/Download.mp3';

    // Start downloading the media file
    await dio.download(url, filePath, onReceiveProgress: (received, total) {
      // Update download progress
      final progress = (received / total * 100).toInt();
      setState(() {
        downloadProgress = progress;
      });
    });

    // Show a message indicating successful download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Media downloaded successfully')),
    );
    print('Downloaded file path: $filePath');

    // Open the downloaded file using OpenFile plugin
    //await OpenFile.open(filePath);
  } catch (e) {
    // Handle errors and log the error message
    print('Error downloading media: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error downloading media: $e')),
    );
  }
}

  

  void playAudio(String url) async {
    MediaItem(
      // Specify a unique ID for each media item:
      id: '${widget.song.id}',
      // Metadata to display in the notification:
      //album: "${widget.song.al}",
      title: "${widget.song.name}",
      artUri: Uri.parse('https://example.com/albumart.jpg'),
    );
    await audioPlayer.play(UrlSource(audios));
  }

  void pauseAudio() async {
    await audioPlayer.pause();
  }

  void loop() {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void stopLoop() {
    audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  bool isLooping() {
    return audioPlayer.releaseMode == ReleaseMode.loop;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<String>.value(
      value: audios,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Audio'),
        ),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: images.isNotEmpty
                      ? Image.network(
                          images,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                ),
                IconButton(
                  onPressed: () {
                    if (audioPlayer.state == PlayerState.playing) {
                      audioPlayer.pause();
                    } else {
                      playAudio(audios);
                    }
                  },
                  icon: Icon(audioPlayer.state == PlayerState.playing
                      ? Icons.pause
                      : Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {
                    if (isLooping()) {
                      stopLoop();
                    } else {
                      loop();
                    }
                  },
                  icon: Icon(
                    isLooping() ? Icons.loop : Icons.loop_outlined,
                    color: isLooping() ? Colors.orange : null,
                  ),
                ),
                IconButton(onPressed: (){
                
                  
                }, icon: Icon(Icons.favorite_border_outlined),),
                ElevatedButton(
                  onPressed: audios.isNotEmpty ? () async {
                    // Check if storage permission is granted
                    if (await _checkStoragePermission()) {
                      await downloadMedia(audios);
                    } else {
                      // If not granted, request the permission
                      await _requestStoragePermission();
                    }
                  } : null,
                  child: const Text('Media Download'),
                ),
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) {
                    final position = Duration(seconds: value.toInt());

                    audioPlayer.seek(position);
                    audioPlayer.resume();
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(position.inSeconds)),
                      Text(formatTime((duration - position).inSeconds)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<bool> _checkStoragePermission() async {
    var status = await Permission.storage.status;
    return status.isGranted;
  }

  // New method to request storage permission
  // New method to request storage permission
Future<void> _requestStoragePermission() async {
  var status = await Permission.storage.request();
  if (!status.isGranted) {
    // Handle permission denied
    print('Permission denied to access storage');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Permission denied to access storage')),
    );
  }
}



  @override
  void dispose() {
    audioPlayer.dispose();
    
    super.dispose();
  }
}
