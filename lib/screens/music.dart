// // import 'dart:convert';

// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:musicfeel/models/apimodel.dart';
// // class MusicScreen extends StatefulWidget {
// //   const MusicScreen({super.key});

// //   @override
// //   State<MusicScreen> createState() => _MusicScreenState();
// // }

// // class _MusicScreenState extends State<MusicScreen> {
// //   List<Song> songs = [];
// //   late ScrollController _scrollController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _scrollController = ScrollController();
// //     fetchSongs();
// //   }

// //   Future<void> fetchSongs() async {
// //     try {
// //       print(widget.songs.id);
// //       final response = await http.get(Uri.parse('https://saavn.dev/albums?id=${widget.songs.id}'));
    
// //       if (response.statusCode == 200) {
// //         final jsonData = json.decode(response.body);
        
// //         if (jsonData.containsKey('data')) {
// //           List<dynamic> songsData = jsonData['data']['downloadUrl'];
// //           List<Song> fetchedSongs = songsData.map((data) => Song.fromJson(data)).toList();
// //           setState(() {
// //             songs = fetchedSongs;
// //           });
// //         } else {
// //           print('No audios data found in API response');
// //         }
// //       } else {
// //         print('Failed to fetch audios. Status code: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       print('Error fetching audios: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return const Placeholder();
// //   }
// // }


// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:musicfeel/models/apimodel.dart';

// class MusicScreen extends StatefulWidget {
//   final Song song;

//   const MusicScreen({Key? key, required this.song}) : super(key: key);

//   @override
//   State<MusicScreen> createState() => _MusicScreenState();
// }

// class _MusicScreenState extends State<MusicScreen> {
//   late String audioUrl;
//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     fetchAudio();
//   }

//   Future<void> fetchAudio() async {
//     try {
//       print(widget.song.id);
//       final response = await http.get(Uri.parse('https://saavn.dev/songs/${widget.song.id}/audio'));

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);

//         if (jsonData.containsKey('downloadUrl')) {
//           setState(() {
//             audioUrl = jsonData['downloadUrl'];
//           });
//         } else {
//           print('No audio data found in API response');
//         }
//       } else {
//         print('Failed to fetch audio. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching audio: $e');
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio'),
//       ),
//       body: Center(
//         child: audioUrl != null
//             ? ElevatedButton(
//                 onPressed: () {
//                   // Handle audio playback here using audioUrl
//                 },
//                 child: Text('Play Audio'),
//               )
//             : CircularProgressIndicator(),
//       ),
//     );
//   }
// }
