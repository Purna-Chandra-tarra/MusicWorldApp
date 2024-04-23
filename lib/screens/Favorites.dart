// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:audioapp/models/songsmodel.dart';

// // class FavoriteSongsScreen extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder(
// //       future: getUserFavoriteSongs(),
// //       builder: (context, AsyncSnapshot<List<Song>> snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return Center(
// //             child: CircularProgressIndicator(),
// //           );
// //         } else if (snapshot.hasError) {
// //           return Center(
// //             child: Text('Error: ${snapshot.error}'),
// //           );
// //         } else {
// //           // Data has been successfully fetched
// //           List<Song> favoriteSongs = snapshot.data!;
          
// //           // Now you can print the user's favorite songs
// //           print('User\'s favorite songs:');
// //           for (var song in favoriteSongs) {
// //             print('Song ID: ${song.id}');
// //             print('Song Name: ${song.name}');
// //             print('Artist: ${song.image[0]['link']}');
// //             print('Download URL: ${song.downloadUrl[0]['link']}');
// //             print('-------------------------');
// //           }

// //           // Placeholder for UI display (you can replace this with your UI code)
// //           return Container(); // Return an empty container for now
// //         }
// //       },
// //     );
// //   }

// //   Future<List<Song>> getUserFavoriteSongs() async {
// //     try {
// //       String userId = FirebaseAuth.instance.currentUser!.uid;
// //       final userFavoriteSongsCollection = FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(userId)
// //           .collection('favorites');

// //       final allFavoriteSongs = await userFavoriteSongsCollection.get();
// //       final List<Song> favoriteSongsList = [];
// //       for (var doc in allFavoriteSongs.docs) {
// //         favoriteSongsList.add(Song(
// //           id: doc['id'],
// //           name: doc['name'],
// //           image: [
// //             {'link': doc['artist']}
// //           ],
// //           downloadUrl: [
// //             {'link': doc['url']}
// //           ],
// //           // Add more fields as needed
// //         ));
// //       }
// //       return favoriteSongsList;
// //     } catch (e) {
// //       print('Error fetching favorite songs: $e');
// //       return []; // Return an empty list in case of error
// //     }
// //   }
// // }
import 'package:audioapp/screens/songslistscreen.dart';
import 'package:audioapp/utils/songs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioapp/models/songsmodel.dart';
import 'package:get/get.dart';

class FavoriteSongsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserFavoriteSongs(),
      builder: (context, AsyncSnapshot<List<Song>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          // Data has been successfully fetched
          List<Song> favoriteSongs = snapshot.data!;
          
          // Now you can display the user's favorite songs
          return ListView.builder(
            itemCount: favoriteSongs.length,
            itemBuilder: (context, index) {
              Song song = favoriteSongs[index];
              // return SongsCard(song: song, onSelectedSong: (song){
              //   Get.to(SongsListScreen(song: song,));
              // });
              return ListTile(
                title: Text(song.name),
                subtitle: Text(song.image[0]['link']), // Assuming this is the artist
                onTap: () {
                  // Handle tapping on the song if needed
                },
              );
            },
          );
        }
      },
    );
  }

  Future<List<Song>> getUserFavoriteSongs() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      final userFavoriteSongsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites');

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
          // Add more fields as needed
        ));
      }
      return favoriteSongsList;
    } catch (e) {
      print('Error fetching favorite songs: $e');
      return []; // Return an empty list in case of error
    }
  }
}
// import 'package:audioapp/screens/songslistscreen.dart';
// import 'package:audioapp/utils/songs.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:audioapp/models/songsmodel.dart';
// import 'package:get/get.dart';

// class FavoriteSongsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: getUserFavoriteSongs(),
//       builder: (context, AsyncSnapshot<List<Song>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error: ${snapshot.error}'),
//           );
//         } else {
//           // Data has been successfully fetched
//           List<Song> favoriteSongs = snapshot.data!;
//           print(favoriteSongs);
          
//           // Now you can display the user's favorite songs
//           return ListView.builder(
//             itemCount: favoriteSongs.length,
//             itemBuilder: (context, index) {
//               //Song song = favoriteSongs[index];
//               //String artist = song.image.isNotEmpty ? song.image[0]['link'] : "Unknown Artist";
//               return SongsCard(
//                 song: favoriteSongs[index],
//                 onSelectedSong: (song) {
                  
//                 },
//               );
//             },
//           );
//         }
//       },
//     );
//   }

//   Future<List<Song>> getUserFavoriteSongs() async {
//     try {
//       String userId = FirebaseAuth.instance.currentUser!.uid;
//       final userFavoriteSongsCollection = FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('favorites');

//       final allFavoriteSongs = await userFavoriteSongsCollection.get();
//       final List<Song> favoriteSongsList = [];
//       for (var doc in allFavoriteSongs.docs) {
//         favoriteSongsList.add(Song(
//           id: doc['id'],
//           name: doc['name'],
//           image: [
//             {'link': doc['artist']}
//           ],
//           downloadUrl: [
//             {'link': doc['url']}
//           ],
//           // Add more fields as needed
//         ));
//       }
//       return favoriteSongsList;
//     } catch (e) {
//       print('Error fetching favorite songs: $e');
//       return []; // Return an empty list in case of error
//     }
//   }
// }
