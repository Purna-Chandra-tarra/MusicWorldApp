import 'dart:convert';

import 'package:audioapp/models/album_model.dart';
import 'package:audioapp/models/chartsmodel.dart';
import 'package:audioapp/models/language.dart';
import 'package:audioapp/models/playlistmodel.dart';
import 'package:audioapp/models/songsmodel.dart';
import 'package:audioapp/models/trendingalbum.dart';
import 'package:audioapp/models/trendingsongsmodel.dart';
import 'package:audioapp/screens/audioscreen.dart';
import 'package:audioapp/screens/chartscreen.dart';
import 'package:audioapp/screens/playlist_songs.dart';
import 'package:audioapp/screens/searchresult.dart';
import 'package:audioapp/screens/songslistscreen.dart';
import 'package:audioapp/screens/trendaudio.dart';
import 'package:audioapp/screens/trendingsongscreen.dart';
import 'package:audioapp/utils/charts.dart';
import 'package:audioapp/utils/dimensions.dart';
import 'package:audioapp/utils/homeutil.dart';
import 'package:audioapp/utils/playlist.dart';
import 'package:audioapp/utils/trendalbum.dart';
import 'package:audioapp/utils/trendsong.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Language? language;
  final TrendSong? trendSong;
  //final void Function(Song song) onToggleFavorite;

  const HomeScreen({
    Key? key,
    required this.language,
    this.trendSong
  }) : super(
          key: key,
        );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 2))
        ..repeat();
  //final void Function(Song song) onToggleFavorite;
  List<Album> albums = [];
  TrendSong? selectedtrendSong;
  List<Playlist> playlists = [];
  List<Song> songs = [];
  List<Chart> charts = [];
  List<TrendSong> trendingsongs = [];
  List<TrendAlbum> trendingalbums = [];
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
  late final void Function(Song song) onToggleFavorite;
  late ScrollController _scrollController1;
  late ScrollController _scrollController3;
  late ScrollController _scrollController2;
  late ScrollController _scrollController4;
  late Type type;
  
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
    fetchAlbums();
    _scrollController1 = ScrollController();
    _scrollController3 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController4 = ScrollController();
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
   
  }

   Future<void> fetchAudios() async {
  try {
    print(widget.trendSong!.id); // Check if the trend song ID is valid
    final response = await http.get(Uri.parse('https://jiosavvan.vercel.app/songs?id=${widget.trendSong!.id}'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData); // Check the JSON data received from the API
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


  Future<void> fetchAlbums() async {
    print(widget.language!.title);
    final response = await http.get(Uri.parse(
        'https://jiosavvan.vercel.app/modules?language=${widget.language!.title}'));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body)['data'];

      List<Album> fetchedAlbums = [];
      List<Playlist> fetchedPlaylists = [];
      List<Song> fetchedSongs = [];
      List<Chart> fetchedCharts = [];
      List<TrendSong> fetchedTrendingSongs = [];
      List<TrendAlbum> fetchedTrendingAlbums = [];
      if (jsonData.containsKey('charts')) {
        List<dynamic> chartsData = jsonData['charts'];
        fetchedCharts = chartsData.map((data) => Chart.fromJson(data)).toList();
      }
      if (jsonData.containsKey('trending') && jsonData['trending'] != null) {
        List<dynamic> trendingsongsData = jsonData['trending']['songs'];
        print(trendingsongsData);
        print(
            "Number of trending songs: ${trendingsongsData.length}"); // Use trendingsongsData.length instead of trendingsongs.length
        fetchedTrendingSongs =
            trendingsongsData.map((data) => TrendSong.fromJson(data)).toList();
      }
      if (jsonData.containsKey('trending') && jsonData['trending'] != null) {
        List<dynamic> trendingalbumsData = jsonData['trending']['albums'];
        print(trendingalbumsData);
        print(
            "Number of trending Album: ${trendingalbumsData.length}"); // Use trendingsongsData.length instead of trendingsongs.length
        fetchedTrendingAlbums = trendingalbumsData
            .map((data) => TrendAlbum.fromJson(data))
            .toList();
      }

      if (jsonData.containsKey('albums')) {
        List<dynamic> albumsData = jsonData['albums'];
        for (var data in albumsData) {
          if (data['type'] == 'album') {
            fetchedAlbums.add(Album.fromJson(data));
          }
        }
      }
      if (jsonData.containsKey('albums')) {
        List<dynamic> albumsData = jsonData['albums'];
        for (var data in albumsData) {
          if (data['type'] == 'song') {
            fetchedAlbums.add(Album.fromJson(data));
          }
        }
      }

      if (jsonData.containsKey('playlists')) {
        List<dynamic> playlistsData = jsonData['playlists'];
        fetchedPlaylists =
            playlistsData.map((data) => Playlist.fromJson(data)).toList();
      }

      setState(() {
        albums = [...fetchedAlbums];
        playlists = [...fetchedPlaylists];
        songs = [...fetchedSongs];
        charts = [...fetchedCharts];
        trendingsongs = [...fetchedTrendingSongs];
        trendingalbums = [...fetchedTrendingAlbums];
      });
    }
  }

  void _selectAlbum(BuildContext context, Album album) {
    // Navigate to SongsListScreen and pass the selected album

    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => SongsListScreen(
                album: album,
              )),
    );
  }

  void _selectSong(BuildContext context, Song song) {
    // Navigate to SongsListScreen and pass the selected album

    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => AudioScreen(
                song: song,
              )),
    );
  }

  void _selectPlaylist(BuildContext context, Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => PlaylistSongsList(
                playlist: playlist,
              )),
    );
  }

  void _selecttrendalbum(BuildContext context, TrendAlbum trendAlbum) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => TrendAlubmlist(
                trendAlbum: trendAlbum,
              )),
    );
  }

  void _selectChart(BuildContext context, Chart chart) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => ChartSongList(
                chart: chart,
              )),
    );
  }

  void _selecttrendSong(TrendSong trendSong) {
    setState(() {
       selectedtrendSong = trendSong;
      playAudio(audios);
     startRotationAnimation();
    });
    fetchAudios();
   
    // Navigate to SongsListScreen and pass the selected album
   
    
  }
   void pauseAudio() async {
    await audioPlayer.pause();
    _controller.stop();
  }
void playAudio(String url) async {
  print("Selected trend song download URLs: ${selectedtrendSong!.url}");
  if (selectedtrendSong!.downloadUrl.isNotEmpty) {
    print("Attempting to play audio with URL: $url"); // Add this line to check the URL being used
    await audioPlayer.play(UrlSource(url));
  } else {
    print("No download URLs found for the selected trend song.");
  }
}



   void playNext() {
    int currentIndex = trendingsongs.indexOf(selectedtrendSong!);
    if (currentIndex < trendingsongs.length - 1) {
      TrendSong nextSong = trendingsongs[currentIndex + 1];
      _selecttrendSong(nextSong);
    }
  }
   void playPrevious() {
    int currentIndex = trendingsongs.indexOf(selectedtrendSong!);
    if (currentIndex > 0) {
      TrendSong previousSong = trendingsongs[currentIndex - 1];
      _selecttrendSong(previousSong);
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

  void _selectSearch(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => SearchScreenSongs()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MUSIC'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: albums.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : GestureDetector(
                    onTap: () {
                      _scrollController1.animateTo(
                          _scrollController1.position.pixels + 200,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                    },
                    child: Column(
                      children: [
                        TextField(
                          onTap: () {
                            _selectSearch(context);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Albums...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "Albums",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 0, right: 0),
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  controller: _scrollController1,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: albums.length,
                                  itemBuilder: (context, index) {
                                    return SongCard(
                                        album: albums[index],
                                        onSelectedAlbum: (album) {
                                          _selectAlbum(context, album);
                                        });
                                  }),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Charts",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 0, right: 0),
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  controller: _scrollController2,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: charts.length,
                                  itemBuilder: (context, index) => ChartslistCard(
                                        chart: charts[index],
                                        onSelectedChart: (chart) =>
                                            _selectChart(context, chart),
                                      )),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "PlayLists",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 0, right: 0),
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                controller: _scrollController3,
                                scrollDirection: Axis.horizontal,
                                itemCount: playlists.length,
                                itemBuilder: (context, index) => PlaylistCard(
                                  playlist: playlists[index],
                                  onSelectedPlaylist: (playlist) =>
                                      _selectPlaylist(context, playlist),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Trending Songs",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 0, right: 0),
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                controller: _scrollController4,
                                scrollDirection: Axis.horizontal,
                                itemCount: trendingsongs.length,
                                itemBuilder: (context, index) => TrendSongCardlist(
                                  trendSong: trendingsongs[index],
                                  onSelectedTrendSong: (trendSong) =>
                                      _selecttrendSong(trendingsongs[index]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Trending Albums",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 0, right: 0),
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  controller: _scrollController4,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: trendingalbums.length,
                                  itemBuilder: (context, index) => TrendlistCard(
                                        trendAlbum: trendingalbums[index],
                                        onSelectedTrendAlbum: (trendAlbum) =>
                                            _selecttrendalbum(context, trendAlbum),
                                      )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          if(selectedtrendSong != null)
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
                                            if (selectedtrendSong!.image.isNotEmpty)
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
                                                    selectedtrendSong!
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
                                                  // setState(() {
                                                  //   songFavorite(
                                                  //       selectedtrendSong!); // Call songFavorite() here
                                                  // });
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
    );
  }
}
