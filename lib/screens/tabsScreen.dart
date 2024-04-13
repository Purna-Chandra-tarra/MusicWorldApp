
import 'package:audioapp/models/album_model.dart';
import 'package:audioapp/models/songsmodel.dart';
import 'package:audioapp/screens/LanguageScreen.dart';
import 'package:audioapp/screens/songslistscreen.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  //var collection = FirebaseFirestore.instance.collection("user");
  int _selectedPageIndex = 0;
  late Album album;
  final List<Song> _favoriteSongs = [];

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _toggleSongFavoriteStatus(Song song) {
    final isExisting = _favoriteSongs.contains(song);

    if (isExisting) {
      setState(() {
        _favoriteSongs.remove(song);
      });
      _showInfoMessage("Song is no logger a Favorite.");
    } else {
      setState(() {
        _favoriteSongs.add(song);
      });
      _showInfoMessage("Song is marked as a Favorite");
    }
  }
//   void _toggleSongFavoriteStatus(Song song) async {
//   final isExisting = _favoriteSongs.contains(song);

//   if (isExisting) {
//     setState(() {
//       _favoriteSongs.remove(song);
//     });
//     await collection.doc(song.id).delete(); // Remove song from Firestore
//     _showInfoMessage("Song is no longer a Favorite.");
//   } else {
//     setState(() {
//       _favoriteSongs.add(song);
//     });
//     await collection.doc(song.id).set(song.toMap()); // Add song to Firestore
//     _showInfoMessage("Song is marked as a Favorite");
//   }
// }


  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = LanguageScreen(
      onToggleFavorite: _toggleSongFavoriteStatus,
    );
    var activePageTitel = 'Languages';
    if (_selectedPageIndex == 1) {
      activePage = SongsListScreen(
        // songs: _favoriteSongs,
        
      );
      print(_favoriteSongs);
      activePageTitel = 'Your Favorites';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitel),
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
