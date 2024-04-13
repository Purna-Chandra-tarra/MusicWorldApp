import 'package:audioapp/models/playlistmodel.dart';
import 'package:flutter/material.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard(
      {super.key, required this.playlist, required this.onSelectedPlaylist});
  final Function(Playlist playlist) onSelectedPlaylist;
  @override
  Widget build(BuildContext context) {
    String cleanTitle = playlist.title.replaceAll(RegExp(r'&quot;'), '').trim();
    return InkWell(
      onTap: () {
        onSelectedPlaylist(playlist);
      },
      
      child: Container(
        height: 40,
        width: 110,
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            playlist.image.isNotEmpty
                ? Image.network(
                    playlist.image[2]['link'],
                    height: 100,
                    width: 100,
                  )
                : Icon(Icons.image),
            const SizedBox(
              height: 20,
            ),
            Text(
              cleanTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color.fromARGB(240, 0, 0, 0),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
