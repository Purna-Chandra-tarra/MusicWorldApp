

import 'package:audioapp/SearchedSongs/albumsongs.dart';
import 'package:audioapp/SearchedSongs/playlistsearchedsong.dart';
import 'package:audioapp/SearchedSongs/topcharts.dart';
import 'package:audioapp/models/album_model.dart';
import 'package:audioapp/screens/songslistscreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchScreenSongs extends StatefulWidget {
  const SearchScreenSongs({Key? key}) : super(key: key);

  @override
  State<SearchScreenSongs> createState() => _SearchScreenSongsState();
}

class _SearchScreenSongsState extends State<SearchScreenSongs> {
  List<dynamic> topChartsWidgets = [];
  List<dynamic> albumsWidgets = [];
  List<dynamic> songsWidgets = [];
  List<dynamic> artistsWidgets = [];
  List<dynamic> playlistsWidgets = [];
  TextEditingController _searchController = TextEditingController();

  Future<void> searchSongs(String query) async {
    final response = await http.get(Uri.parse('https://saavn.dev/api/search?query=${query}'));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData.containsKey('data')) {
        var data = jsonData['data'];

        if (data.containsKey('topQuery')) {
          var topQuery = data['topQuery'];
          if (topQuery.containsKey('results')) {
            var results = topQuery['results'];
            topChartsWidgets.clear();
            topChartsWidgets.addAll(results);
          }
        }

        if (data.containsKey('albums')) {
          var albums = data['albums'];
          if (albums.containsKey('results')) {
            var results = albums['results'];
            albumsWidgets.clear();
            albumsWidgets.addAll(results);
          }
        }

        if (data.containsKey('songs')) {
          var songs = data['songs'];
          if (songs.containsKey('results')) {
            var results = songs['results'];
            songsWidgets.clear();
            songsWidgets.addAll(results);
          }
        }

        if (data.containsKey('artists')) {
          var artists = data['artists'];
          if (artists.containsKey('results')) {
            var results = artists['results'];
            artistsWidgets.clear();
            artistsWidgets.addAll(results);
          }
        }

        if (data.containsKey('playlists')) {
          var playlists = data['playlists'];
          if (playlists.containsKey('results')) {
            var results = playlists['results'];
            playlistsWidgets.clear();
            playlistsWidgets.addAll(results);
          }
        }

        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    searchSongs('');
  }
  void _selectAlbum(BuildContext context , String albumId,List<dynamic> albumImage, String? title) {
  // Navigate to SongsListScreen and pass the selected album ID
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => SearchedAlbum(albumId: albumId, albumImage: albumImage, title: title,),
    ),
  );
}
void _selectPlaylist(BuildContext context, String playlistId ,List<dynamic> playlistImage, String? title) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) =>SearchPlaylist(playlistId: playlistId, playlistImage: playlistImage, title: title,)),
    );
  }
    void _selectChart(BuildContext context, String chartId, List<dynamic> chartImage, String? title) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => SearchedTopCharts(chartId: chartId, chartImage: chartImage, title: title,),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for songs',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                String query = _searchController.text;
                if (query.isNotEmpty) {
                  searchSongs(query);
                }
              },
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Top Charts'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: topChartsWidgets.length,
            itemBuilder: (BuildContext context, int index) {
              var item = topChartsWidgets[index];
              return ListTile(
                title: Text(item['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Album: ${item['album']}'),
                    Text('Description: ${item['description']}'),
                    Text('Type: ${item['type']}'),
                   Text('id : ${item['id']}'),
                  ],
                ),
                leading: Image.network(item['image'][0]['url']), // Assuming the first image is the main image
                onTap: () {
                 _selectChart(context, item['id'], item['image'], item['title']);
                },
              );
            },
          ),
          ListTile(
            title: Text('Albums'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: albumsWidgets.length,
            itemBuilder: (BuildContext context, int index) {
              var item = albumsWidgets[index];
              return ListTile(
                title: Text(item['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Album: ${item['album']}'),
                    Text('Description: ${item['description']}'),
                    Text('Type: ${item['type']}'),
                    Text('id : ${item['id']}'),
                  ],
                ),
                leading: Image.network(item['image'][0]['url']), // Assuming the first image is the main image
                onTap: () {
               _selectAlbum(context, item['id'],item['image'], item['title']);
                },
              );
            },
          ),
          ListTile(
            title: Text('songs'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: songsWidgets.length,
            itemBuilder: (BuildContext context, int index) {
              var item = songsWidgets[index];
              return ListTile(
                title: Text(item['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Album: ${item['album']}'),
                    Text('Description: ${item['description']}'),
                    Text('Type: ${item['type']}'),
                   
                  ],
                ),
                leading: Image.network(item['image'][0]['url']), // Assuming the first image is the main image
                onTap: () {
                  // Handle tap event if needed
                },
              );
            },
          ),
          // ListTile(
          //   title: Text('artists'),
          // ),
          // ListView.builder(
          //   shrinkWrap: true,
          //   physics: NeverScrollableScrollPhysics(),
          //   itemCount: artistsWidgets.length,
          //   itemBuilder: (BuildContext context, int index) {
          //     var item = artistsWidgets[index];
          //     return ListTile(
          //       title: Text(item['title']),
          //       subtitle: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text('Album: ${item['album']}'),
          //           Text('Description: ${item['description']}'),
          //           Text('Type: ${item['type']}'),
                   
          //         ],
          //       ),
          //       leading: Image.network(item['image'][0]['url']), // Assuming the first image is the main image
          //       onTap: () {
          //         // Handle tap event if needed
          //       },
          //     );
          //   },
          // ),
          ListTile(
            title: Text('playlists'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: playlistsWidgets.length,
            itemBuilder: (BuildContext context, int index) {
              var item = playlistsWidgets[index];
              return ListTile(
                title: Text(item['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Album: ${item['album']}'),
                    Text('Description: ${item['description']}'),
                    Text('Type: ${item['type']}'),
                   
                  ],
                ),
                leading: Image.network(item['image'][0]['url']), // Assuming the first image is the main image
                onTap: () {
                  _selectPlaylist(context, item['id'], item['Image'], item['title']);
                  // Handle tap event if needed
                },
              );
            },
          ),
          // Similar implementation for Albums, Songs, Artists, and Playlists
        ],
      ),
    );
  }
}

