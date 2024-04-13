// import 'package:audioapp/models/songsmodel.dart';
// import 'package:flutter/material.dart';

// class MusicPlayerState extends ChangeNotifier {
//   bool _isPlaying = false;
//   Song? _currentSong;

//   bool get isPlaying => _isPlaying;
//   Song? get currentSong => _currentSong;

//   void play(Song song) {
//     _currentSong = song;
//     _isPlaying = true;
//     // Logic to play the song
//     notifyListeners();
//   }

//   void pause() {
//     _isPlaying = false;
//     // Logic to pause the song
//     notifyListeners();
//   }

//   void togglePlayPause() {
//     if (_isPlaying) {
//       pause();
//     } else {
//       if (_currentSong != null) {
//         play(_currentSong!);
//       }
//     }
//   }
// }
// import 'package:audioapp/models/songsmodel.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';

// class AudioPlayerState extends ChangeNotifier {
//   late Song selectedSong;
//   late final AudioPlayer audioPlayer = AudioPlayer();
  

//   Future<void> play(String url) async {
//     await audioPlayer.play(UrlSource(selectedSong!.downloadUrl.last['link']));
//     notifyListeners();
//   }

//   Future<void> pause() async {
//     await audioPlayer.pause();
//     notifyListeners();
//   }

//   // Other methods like stop, seek, etc.

//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }
// }
