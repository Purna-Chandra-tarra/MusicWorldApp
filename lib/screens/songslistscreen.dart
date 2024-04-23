import 'dart:convert';
import 'package:audioapp/models/album_model.dart';
import 'package:audioapp/models/songsmodel.dart';
import 'package:audioapp/utils/dimensions.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:audioapp/utils/songs.dart';

class SongsListScreen extends StatefulWidget {
  final Album? album;
  final String? userId;
  final Song? song;
  final String? albumId;

  const SongsListScreen({
    Key? key,
    this.album,
    this.song,
    this.albumId,
    this.userId,
  }) : super(key: key);

  @override
  State<SongsListScreen> createState() => _SongsListScreenState();
}

class _SongsListScreenState extends State<SongsListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 2))
        ..repeat();
  List<Song> songs = [];
  bool isLoading = true;
  String audios = "";
  String images = "";
  bool isFavorite = false;
  bool loopEnabled = false;
  int _currentlyPlayingIndex = 0;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  Song? selectedSong;
  late ScrollController _scrollController;
  late AudioPlayer audioPlayer;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    audioPlayer = AudioPlayer();

    // Add event listeners for audio player
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

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
            isLoading = false;
          });
        } else {
          print('No songs data found in API response');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print(
            'Failed to fetch songs. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching songs: $e');
      setState(() {
        isLoading = false;
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

          String lastUrl = audiosData.last['link'];
          String lastImage = imagesData.last['link'];

          setState(() {
            audios = lastUrl;
            images = lastImage;
          });
        } else {
          print('No audio data found in API response');
        }
      } else {
        print(
            'Failed to fetch audio. Status code: ${response.statusCode}');
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
  }

  void pauseAudio() async {
    await audioPlayer.pause();
    _controller.stop();
  }

  void playAudio(String url) async {
    if (selectedSong!.downloadUrl.isNotEmpty) {
      await audioPlayer.play(UrlSource(selectedSong!.downloadUrl.last['link']));
    } else {
      print("No download URLs found for the selected song.");
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

  Future<void> checkFavoriteStatus() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      final userFavoriteSongsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites');
      final snapshot =
          await userFavoriteSongsCollection.doc(widget.song!.id).get();

      setState(() {
        isFavorite = snapshot.exists;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> songFavorite(Song song) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      final userFavoriteSongsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites');
      final snapshot = await userFavoriteSongsCollection
          .where('id', isEqualTo: song.id)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Song removed from favorites')),
        );
      } else {
        await userFavoriteSongsCollection.add({
          "id": song.id,
          "name": song.name,
          "artist": song.image.last['link'],
          "album": song.id,
          "url": song.downloadUrl.last['link'],
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Song added to favorites')),
        );
      }

      final allFavoriteSongs = await userFavoriteSongsCollection.get();
      final List<Song> favoriteSongsList = [];
      for (var doc in allFavoriteSongs.docs) {
        favoriteSongsList.add(Song(
          id: doc['id'],
          name: doc['name'],
          image: [
            {'link': doc['artist']}
          ],
          downloadUrl: [
            {'link': doc['url']}
          ],
        ));
      }
      final isSongFavorite =
          favoriteSongsList.any((favoriteSong) => favoriteSong.id == song.id);
      setState(() {
        isFavorite = isSongFavorite;
      });
      favoriteSongsList.removeWhere((favSong) => favSong.id == song.id);
    } catch (e) {
      print('Error modifying favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to modify favorites')),
      );
    }
  }

 void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }
  Widget _buildFullScreenContainer() {
    // Track currently playing song index

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
                      // Add logic to play the corresponding song when image changes
                      _selectSong(songs[index + 1]);
                      playAudio(songs[index + 1].downloadUrl.last['link']);
                    },
                    controller: PageController(),
                    itemBuilder: (context, index) {
                      // int previousIndex = (index - 1) % songs.length;
                      // int nextIndex = (index + 1) % songs.length;
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
                                songs[index]
                                    .name, // Display song name below the image
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  //
                  // ),
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
                              audioPlayer.state == PlayerState.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 45,
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
                    //  SizedBox(height: SizeConfig.blockSizeVertical*30,)
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
                    if (widget.album != null && widget.album!.image.isNotEmpty)
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
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.song?.name ?? '', // Null safety check
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
                                                color: isFavorite ?? false
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
    }