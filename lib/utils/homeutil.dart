import 'package:audioapp/models/album_model.dart';
import 'package:flutter/material.dart';

class SongCard extends StatelessWidget {
  final Album album;

  const SongCard({Key? key, required this.album, required this.onSelectedAlbum})
      : super(key: key);
  final Function(Album album) onSelectedAlbum;
  @override
  Widget build(BuildContext context) {
    String cleanName = album.name.replaceAll(RegExp(r'&quot;'), '').trim();

    return InkWell(
      onTap: () {
        onSelectedAlbum(album);
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
            album.image.isNotEmpty
                ? Image.network(
                    album.image[2]['link'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.image),
            const SizedBox(
              height: 20,
            ),
            Text(
              cleanName,
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
