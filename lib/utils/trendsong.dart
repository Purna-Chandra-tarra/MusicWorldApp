import 'package:audioapp/models/trendingsongsmodel.dart';
import 'package:flutter/material.dart';

class TrendSongCardlist extends StatelessWidget {
  final TrendSong trendSong;
  const TrendSongCardlist({super.key, required this.trendSong, required this.onSelectedTrendSong});
  final Function(TrendSong trendong) onSelectedTrendSong;

  @override
  Widget build(BuildContext context) {
    String cleanName = trendSong.name.replaceAll(RegExp(r'&quot;'), '').trim();
    return InkWell(
      onTap: (){
        onSelectedTrendSong(trendSong);
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
              trendSong.image.isNotEmpty
                  ? Image.network(
                      trendSong.image[2]['link'],
                      height: 100,
                      width:100,
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