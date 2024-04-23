import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:audioapp/models/chartsmodel.dart';
import 'package:audioapp/models/songsmodel.dart';
import 'package:audioapp/utils/dimensions.dart';
import 'package:audioapp/utils/songs.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChartSongList extends StatefulWidget {
  final Chart chart;
  final Song? song;
  final String? songUrl; // URL of the song to be downloaded
  final String? fileName; // Name to be given to the downloaded file

  const ChartSongList({
    Key? key,
    required this.chart,
    this.song,
    this.fileName,
    this.songUrl,
  }) : super(key: key);

  @override
  State<ChartSongList> createState() => _ChartSongListState();
}

class _ChartSongListState extends State<ChartSongList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 2))
        ..repeat();
  List<Song> songs = [];
  late AudioCache audioCache;
  int _currentlyPlayingIndex = 0;
  double _downloadProgress = 0.0;
  int nextIndex = 0;
  String audios = "";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isFavorite = false;
  bool loopEnabled = false;
  bool isPlaying = false;
  String images = "";
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  Song? selectedSong;
  bool isFullScreen = false;
  late AudioPlayer audioPlayer;
  late ScrollController _scrollController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60; // Calculate minutes
    int remainingSeconds = seconds % 60; // Calculate remaining seconds
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    audioCache = AudioCache();

    _scrollController = ScrollController();
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
          if (isPlaying) {
            startRotationAnimation();
          } else {
            stopRotationAnimation();
          }
        });
      }
    });

    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        if (mounted) {
          playNext();
        }
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
          startRotationAnimation();
        });
      }
    });

    fetchSongs();
    _registerDownloadCallback();

    // Initialize FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  CollectionReference favoriteSongsCollection =
      FirebaseFirestore.instance.collection('Favoritesongs');

  Future<void> songFavorite(Song song) async {
    try {
      final snapshot = await favoriteSongsCollection
          .where('id', isEqualTo: song.id)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Song is already in favorites, remove it
        await snapshot.docs.first.reference.delete();
        setState(() {
          isFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Song removed from favorites')),
        );
      } else {
        // Song is not in favorites, add it
        await favoriteSongsCollection.add({
          "id": song.id,
          "name": song.name,
          "artist": song.image.last['link'],
          "album": song.id,
          "url": song.downloadUrl
              .last['link'], // Assuming the URL is stored in downloadUrl
          // Add more fields as needed
        });
        setState(() {
          isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Song added to favorites')),
        );
      }
    } catch (e) {
      print('Error modifying favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to modify favorites')),
      );
    }
  }

  void _registerDownloadCallback() {
    FlutterDownloader.registerCallback((id, status, progress) {
      if (status == DownloadTaskStatus.running) {
        setState(() {
          _downloadProgress = progress.toDouble();
        });
      } else if (status == DownloadTaskStatus.complete) {
        print('Download task ID: $id completed successfully');
      }
    });
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      downloadFile(audios, images);
    } else {
      // Permission denied, handle accordingly
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
    try {
      if (await Permission.storage.request().isGranted) {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final savedDir = directory.path;
          final taskId = await FlutterDownloader.enqueue(
            url: audios,
            savedDir: savedDir,
            fileName: fileName,
            showNotification: true,
            openFileFromNotification: true,
          );

          print('Download task ID: $taskId');
          print('File saved at: $savedDir/$fileName');
        } else {
          throw FileSystemException('Failed to get external storage directory');
        }
      } else {
        throw PlatformException(
            code: 'PERMISSION_DENIED', message: 'Storage permission denied');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future<void> fetchSongs() async {
    try {
      print(widget.chart.id);
      final response = await http.get(Uri.parse(
          'https://jiosavvan.vercel.app/playlists?id=${widget.chart.id}'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('data')) {
          List<dynamic> songsData = jsonData['data']['songs'];
          List<Song> fetchedSongs =
              songsData.map((data) => Song.fromJson(data)).toList();
          setState(() {
            songs = fetchedSongs;
          });
        } else {
          print('No songs data found in API response');
        }
      } else {
        print('Failed to fetch songs. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching songs: $e');
    }
  }

  Future<void> fetchAudios() async {
    try {
      print(widget.song!.id);
      final response = await http.get(Uri.parse(
          'https://jiosavvan.vercel.app/songs?id=${widget.song!.id}'));
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

  void _selectSong(Song song) {
    setState(() {
      selectedSong = song;
      _currentlyPlayingIndex = songs.indexOf(song);
      playAudio(audios);
      startRotationAnimation();
    });
    fetchAudios();
     showNotification(song);
  }

  void pauseAudio() async {
    await audioPlayer.pause();
    _controller.stop();
  }

  void playAudio(String url) async {
    await audioPlayer.play(UrlSource(selectedSong!.downloadUrl.last['link']));

    // Show notification
    showNotification(selectedSong!);
  }
  Future<void> showNotification(Song song) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
         "flutterEmbedding",
          "2",
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Extract the song name and images from the Song object
  final String songName = song.name;
  final List<Map<String, dynamic>> songImages = song.image;

  // Assuming you want to display only the first image of the song in the notification
  final String songImage = songImages.isNotEmpty ? songImages[0]['url'] : '';

  // Now, show the notification with the song image and name
  await flutterLocalNotificationsPlugin.show(
    0,
    'Now playing',
    songName,
    platformChannelSpecifics,
    payload: songImage, // Pass the song image URL as payload if needed
  );
}

  void playNext() {
    int currentIndex = songs.indexOf(selectedSong!);
    if (currentIndex < songs.length - 1) {
      Song nextSong = songs[currentIndex + 1];
      _selectSong(nextSong);
    }
  }

  void playPrevious() {
    int currentIndex = songs.indexOf(selectedSong!);
    if (currentIndex > 0) {
      Song previousSong = songs[currentIndex - 1];
      _selectSong(previousSong);
    }
  }

  void stopRotationAnimation() {
    _controller.stop();
  }

  void startRotationAnimation() {
    _controller.repeat();
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

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  Widget _buildFullScreenContainer() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isFullScreen ? MediaQuery.of(context).size.height : 0,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 0),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16.0),
            color: Color.fromARGB(255, 11, 11, 11),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 350, // Adjust the height of the image row as needed
                  child: PageView.builder(
                    itemCount: songs.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentlyPlayingIndex = index + 1;
                      });
                      _selectSong(songs[index + 1]);
                      playAudio(songs[index + 1].downloadUrl.last['link']);
                    },
                    controller: PageController(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _selectSong(songs[index]);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                child: Image.network(
                                  songs[_currentlyPlayingIndex]
                                      .image
                                      .last['link'],
                                  width: 230,
                                  height: 270,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 40),
                              Text(
                                songs[index].name,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Slider and playback controls
                Column(
                  children: [
                    Column(
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 0, bottom: 10),
                              width: MediaQuery.of(context).size.width * 80,
                              child: Slider(
                                min: 0,
                                max: duration.inSeconds.toDouble(),
                                value: position.inSeconds.toDouble(),
                                onChanged: (value) {
                                  final position =
                                      Duration(seconds: value.toInt());
                                  audioPlayer.seek(position);
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    formatTime(position.inSeconds),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    formatTime((duration).inSeconds),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              downloadFile(audios, images);
                            },
                            icon: Icon(Icons.download),
                          ),
                          _downloadProgress > 0.0
                              ? CircularProgressIndicator(
                                  value: _downloadProgress,
                                  color: Colors.green,
                                )
                              : Container(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                playPrevious();
                              });
                            },
                            icon: Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (audioPlayer.state == PlayerState.playing) {
                                pauseAudio();
                              } else {
                                playAudio(audios);
                                startRotationAnimation();
                              }
                            },
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _controller,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                playNext();
                              });
                            },
                            icon: Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              margin: EdgeInsets.only(
                  bottom: 0,
                  top: 0,
                  left: SizeConfig.blockSizeHorizontal * 15,
                  right: SizeConfig.blockSizeHorizontal * 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  border: Border.all(color: Colors.red)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        loopEnabled = !loopEnabled;
                      });
                    },
                    icon: Icon(
                      loopEnabled ? Icons.loop : Icons.loop_outlined,
                      color: loopEnabled ? Colors.orange : null,
                      size: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        songFavorite(selectedSong!);
                      });
                    },
                    icon: Icon(
                      Icons.favorite,
                      color: isFavorite ? Colors.red : null,
                      size: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        toggleFullScreen();
                      });
                    },
                    icon: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }




 

  @override
  Widget build(BuildContext context) {
    // Wrap your widget with a Provider widget to provide the list of songs
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text('Songs'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 16, 46)),
                  child: Column(
                    children: [
                      if (widget.chart != null && widget.chart.image.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10), // Adjust the border radius as needed
                          child: Container(
                            height: 250, // Adjust height as needed
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the border radius as needed
                              image: DecorationImage(
                                image: NetworkImage(
                                    widget.chart.image.last['link']),
                                fit: BoxFit.cover, // Adjust the fit as needed
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.chart.title,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      Expanded(
                        child: songs.isEmpty
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: songs.length,
                                itemBuilder: (context, index) {
                                  // Check if the current song is present in the Firebase collection
                                  //Future<bool> isSongFavorite = favoriteSongsCollection.doc(songs[index].id).get().then((doc) => doc.exists);

                                  return SongsCard(
                                    song: songs[index],
                                    onSelectedSong: (song) {
                                      _selectSong(songs[index]);
                                    },
                                    // isFavorite: isSongFavorite, // Pass the information about whether the song is favorite to the SongsCard widget
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (selectedSong != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.0),
                          color: Colors.black,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          if (selectedSong!.image.isNotEmpty)
                                            AnimatedBuilder(
                                              animation: _controller,
                                              builder: (context, child) {
                                                return Transform.rotate(
                                                  angle: _controller.value *
                                                      2 *
                                                      math.pi,
                                                  child: child,
                                                );
                                              },
                                              child: ClipOval(
                                                child: Image.network(
                                                  selectedSong!
                                                      .image.last['link'],
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: SizeConfig
                                                            .blockSizeHorizontal *
                                                        60,
                                                    child: Slider(
                                                      min: 0,
                                                      max: duration.inSeconds
                                                          .toDouble(),
                                                      value: position.inSeconds
                                                          .toDouble(),
                                                      onChanged: (value) {
                                                        final position =
                                                            Duration(
                                                                seconds: value
                                                                    .toInt());

                                                        audioPlayer
                                                            .seek(position);
                                                        audioPlayer.resume();
                                                      },
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          formatTime(position
                                                              .inSeconds),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          formatTime((duration)
                                                              .inSeconds),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    playPrevious();
                                                    playAudio(audios);
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.skip_previous,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  if (audioPlayer.state ==
                                                      PlayerState.playing) {
                                                    audioPlayer.pause();
                                                    stopRotationAnimation();
                                                  } else {
                                                    setState(() {
                                                      audioPlayer.resume();
                                                      startRotationAnimation();
                                                    });
                                                  }
                                                },
                                                icon: Icon(
                                                  audioPlayer.state ==
                                                          PlayerState.playing
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    playNext();
                                                    playAudio(audios);
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.skip_next,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    loopEnabled = !loopEnabled;
                                                  });
                                                },
                                                icon: Icon(
                                                  loopEnabled
                                                      ? Icons.loop
                                                      : Icons.loop_outlined,
                                                  color: loopEnabled
                                                      ? Colors.orange
                                                      : null,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    songFavorite(
                                                        selectedSong!); // Call songFavorite() here
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.favorite,
                                                  color: isFavorite
                                                      ? Colors.red
                                                      : null,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    toggleFullScreen();
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.fullscreen,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isFullScreen) _buildFullScreenContainer(),
                  ],
                ),
              ),
          ],
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

class Blob extends StatelessWidget {
  final double rotation;
  final double scale;
  final Color? color;

  const Blob({this.color, this.rotation = 0, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(150),
              topRight: Radius.circular(240),
              bottomLeft: Radius.circular(220),
              bottomRight: Radius.circular(180),
            ),
          ),
        ),
      ),
    );
  }
}
