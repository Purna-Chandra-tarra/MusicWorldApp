import 'package:audioapp/models/trendingalbum.dart';
import 'package:flutter/material.dart';

class TrendlistCard extends StatelessWidget {
  final TrendAlbum trendAlbum;
  const TrendlistCard({super.key, required this.trendAlbum, required this.onSelectedTrendAlbum});
  final Function(TrendAlbum trendAlbum) onSelectedTrendAlbum;

  @override
  Widget build(BuildContext context) {
    String cleanName = trendAlbum.name.replaceAll(RegExp(r'&quot;'), '').trim();
    return InkWell(
      onTap: (){
        onSelectedTrendAlbum(trendAlbum);
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
              trendAlbum.image.isNotEmpty
                  ? Image.network(
                      trendAlbum.image[2]['link'],
                      height: 100,
                      width: 100,
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