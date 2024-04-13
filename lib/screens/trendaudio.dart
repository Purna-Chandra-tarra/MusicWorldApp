import 'dart:convert';

import 'package:audioapp/models/trendingsongsmodel.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TrendAudio extends StatefulWidget {
  final TrendSong trendSong;
  const TrendAudio({super.key, required this.trendSong});

  @override
  State<TrendAudio> createState() => _TrendAudioState();
}

class _TrendAudioState extends State<TrendAudio> {
  late AudioPlayer audioPlayer;
  bool isPlaying=false;
  Duration duration=Duration.zero;
  Duration position=Duration.zero;
  late AudioCache audioCache;
  String audios = " ";
  String images = " ";

  String formatTime(int seconds){
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8,'0');
  }
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioCache = AudioCache();
    audioPlayer.onPlayerStateChanged.listen((state){
      setState(() {
        isPlaying = state==PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration){
      setState(() {
        duration=newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition){
      setState(() {
        position=newPosition;
      });
    });
    fetchAudios();
  }

  Future<void> fetchAudios() async {
    try {
      print(widget.trendSong.id);
      final response = await http.get(Uri.parse(
          'https://jiosavvan.vercel.app/songs?id=${widget.trendSong.id}'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData);
        if (jsonData.containsKey('data')) {
          print("success");

          List<dynamic> audiosData = jsonData['data'][0]['downloadUrl'];
          List<dynamic> imagesData = jsonData['data'][0]['image'];
          print(audiosData);

          // Fetching the last URL
          String lastUrl = audiosData.last['link']; // Accessing the last URL
          String lastimage = imagesData.last['link'];
          print("hello sir");
          print(lastUrl);

          // Assuming you have an Audio class with a constructor that takes a URL
          //  Audio fetchedAudio = Audio.fromJson(lastUrl as Map<String, dynamic>); // Assuming Audio.fromJson can handle a URL string

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

  void playAudio(String url) async {
    await audioPlayer.play(UrlSource(audios));
  }

  void pauseAudio() async {
    await audioPlayer.pause();
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
          child: images.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            ):Container(
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
                Slider(min: 0,max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(), onChanged: (value){
                  final position=Duration(seconds:value.toInt());
                  
                  audioPlayer.seek(position);
                  audioPlayer.resume();
                  
                }),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(position.inSeconds)),
                      Text(formatTime((duration-position).inSeconds)),
                    ],
                  ),
                ),
                
                // ElevatedButton(
                //     onPressed: () {
                //       // final player= AudioPlayer();
                //       // player.play(UrlSource(audios));
                //       playAudio(audios);
                //     },
                //     child: Text("click me")),
                // ElevatedButton(
                //   onPressed: () {
                //     pauseAudio();
                //   },
                //   child: Text("Pause"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
