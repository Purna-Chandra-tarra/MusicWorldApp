// import 'dart:convert';

// import 'package:audioapp/models/album_model.dart';
// import 'package:audioapp/models/songsmodel.dart';
// import 'package:audioapp/screens/audioscreen.dart';
// import 'package:audioapp/utils/songs.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SongsListScreen extends StatefulWidget {
//   final Album? album;
//   final List<Song>? songs;

//   const SongsListScreen({Key? key,  this.album, this.songs}) : super(key: key);

//   @override
//   State<SongsListScreen> createState() => _SongsListScreenState();
// }

// class _SongsListScreenState extends State<SongsListScreen> {
//   List<Song> songs = [];
//   bool isLoading = true;
//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     fetchSongs();
//      Future.delayed(Duration(seconds: 30), () {
//       if (songs.isEmpty) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     });
//   }

//   Future<void> fetchSongs() async {
//     try {
//       print(widget.album!.id);
//       final response = await http.get(Uri.parse('https://jiosavvan.vercel.app/albums?id=${widget.album!.id}'));
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData.containsKey('data')) {
//           List<dynamic> songsData = jsonData['data']['songs'];
//           List<Song> fetchedSongs = songsData.map((data) => Song.fromJson(data)).toList();
//           print(fetchedSongs);
//           setState(() {
//             songs = fetchedSongs;
//           });
//         } else {
//           print('No songs data found in API response');
//         }
//       } else {
//         print('Failed to fetch songs. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching songs: $e');
//     }
//   }

//   void _selectSong(BuildContext context, Song song) {
//     // Navigate to SongsListScreen and pass the selected album
//     Navigator.of(context).push(
//       MaterialPageRoute(builder: (ctx) =>AudioScreen(song: song,)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Wrap your widget with a Provider widget to provide the list of songs
//     return Provider<List<Song>>.value(
//       value: songs, // Provide the list of songs here
//       child: Scaffold(
//         appBar: AppBar(
//           //title: Text('Songs'),
//         ),
//         body: isLoading
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // CircularProgressIndicator(),
//                     // SizedBox(height: 16),
//                     // Text('Loading songs...'),
//                   ],
//                 ),
//               ):songs.isEmpty
//           ?  Center(
//                     child: Text('No songs available.'),
//                   ): ListView.builder(
//           controller: _scrollController,
//           itemCount: songs.length,
//           itemBuilder: (context, index) {
//             return
//              SongsCard(song: songs[index], onSelectedSong:(song){
//               _selectSong(context, song);
//             } ,);
//           },
//         ),
//       ),
//     );
//   }
// }

// Import necessary packages and files

import 'dart:convert';
import 'package:audioapp/utils/dimensions.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:audioapp/models/album_model.dart';
import 'package:audioapp/models/songsmodel.dart';
import 'package:audioapp/utils/songs.dart';

class SongsListScreen extends StatefulWidget {
  final Album? album;

  final Song? song;
  final String? albumId;
  const SongsListScreen({Key? key, this.album, this.song, this.albumId})
      : super(key: key);

  @override
  State<SongsListScreen> createState() => _SongsListScreenState();
}

class _SongsListScreenState extends State<SongsListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 2))
        ..repeat();
  List<Song> songs = [];
  late AudioCache audioCache;
  bool isLoading = true;
  String audios = "";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isFavorite = false;
  bool loopEnabled = false;
  bool isPlaying = false;
  String images = "";
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  Song? selectedSong;
  late AudioPlayer audioPlayer;
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60; // Calculate minutes
    int remainingSeconds = seconds % 60; // Calculate remaining seconds
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    audioPlayer = AudioPlayer();
    audioCache = AudioCache();

    //_scrollController = ScrollController();
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
          startRotationAnimation();
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
      final allFavoriteSongs = await favoriteSongsCollection.get();
      final List<Song> favoriteSongsList = [];
      for (var doc in allFavoriteSongs.docs) {
        favoriteSongsList.add(Song(
          id: doc['id'],
          name: doc['name'],
          image: [
            {'link': doc['artist']}
          ], // Assuming image is a list with a single element
          downloadUrl: [
            {'link': doc['url']}
          ], // Assuming downloadUrl is a list with a single element
          // Add more fields as needed
        ));
      }
      final isSongFavorite =
          favoriteSongsList.any((favoriteSong) => favoriteSong.id == song.id);
      setState(() {
        isFavorite = isSongFavorite;
      });
      favoriteSongsList.removeWhere((song) => song.id == song.id);
    } catch (e) {
      print('Error modifying favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to modify favorites')),
      );
    }
  }

  Future<void> fetchSongs() async {
    try {
      final response = await http.get(Uri.parse(
          'https://jiosavvan.vercel.app/albums?id=${widget.album!.id}'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('data')) {
          List<dynamic> songsData = jsonData['data']['songs'];
          List<Song> fetchedSongs =
              songsData.map((data) => Song.fromJson(data)).toList();
          setState(() {
            songs = fetchedSongs;
            isLoading = false; // Set loading to false after fetching songs
          });
        } else {
          print('No songs data found in API response');
          setState(() {
            isLoading = false; // Set loading to false if no songs data
          });
        }
      } else {
        print('Failed to fetch songs. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false; // Set loading to false if request fails
        });
      }
    } catch (e) {
      print('Error fetching songs: $e');
      setState(() {
        isLoading = false; // Set loading to false if there's an error
      });
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
      playAudio(audios);
      startRotationAnimation();
    });

    fetchAudios();
  }

  void pauseAudio() async {
    await audioPlayer.pause();
    _controller.stop();
  }

  // void playAudio(String url) async {
  //   await audioPlayer.play(UrlSource(selectedSong!.downloadUrl.last['link']));
  // }
 void playAudio(String url) async {
  print("Selected trend song download URLs: ${selectedSong!.downloadUrl}");
  if (selectedSong!.downloadUrl.isNotEmpty) {
   // String lastUrl = selectedtrendSong!.downloadUrl.last['link'];
    await audioPlayer.play(UrlSource(selectedSong!.downloadUrl.last['link']));
  } else {
    print("No download URLs found for the selected trend song.");
  }
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
                color: const Color.fromARGB(255, 0, 16, 46)
              ),
                  child: Column(
                    children: [
                      if (widget.album != null &&
                          widget.album!.image.isNotEmpty)
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
                                    widget.album!.image.last['link']),
                                fit: BoxFit.cover, // Adjust the fit as needed
                              ),
                            ),
                            
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(widget.album!.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),),
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
                                  Future<bool> isSongFavorite =
                                      favoriteSongsCollection
                                          .doc(songs[index].id)
                                          .get()
                                          .then((doc) => doc.exists);

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
                          width: SizeConfig.blockSizeHorizontal*100,
                          // decoration: BoxDecoration(
                          //   border: Border.all(color: Colors.red)
                          // ),
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
                                      Container(
                                        //width: SizeConfig.blockSizeHorizontal*10,
                                        child: Column(
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
                                                  Container(
                                                    // width: SizeConfig.blockSizeHorizontal*30,
                                                    child: Column(
                                                      
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
