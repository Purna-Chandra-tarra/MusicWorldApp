import 'package:audioapp/models/songsmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SongsCard extends StatelessWidget {
  final Song song; // Declare a variable to hold the song data
  final Function(Song song) onSelectedSong;

  const SongsCard({
    Key? key,
    required this.song,
    required this.onSelectedSong,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String songName = song.name.replaceAll(RegExp(r'&quot;'), '').trim();
    return Container(
      height: 80,
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          onSelectedSong(song);
          // Implement onTap functionality if needed
        },
        child: Container(
          // margin: EdgeInsets.only(right:13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              song.image.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                       child: Image.network(
                          song.image[2]['link'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 50,
                              width: 70,
                              color: Colors.grey, // Placeholder color
                              child: Icon(Icons.image, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    )
                  : Container(
                      height: 70,
                      width: 70,
                      color: Colors.grey, // Placeholder color
                      child: Icon(Icons.image, color: Colors.white),
                    ),
              //SizedBox(height: 8),
              // Display the song's name
              // Expanded(

              //   child: Text(
              //     songName,
              //     maxLines: 1,
              //     overflow: TextOverflow.ellipsis,
              //     style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 16,
              //       color: Color.fromARGB(240, 0, 0, 0),
              //     ),

              //   ),
              // ),
              // Container(
              //   // decoration: BoxDecoration(
              //   //   border: Border.all(color: Colors.red),
              //   // ),
              //   margin: EdgeInsets.only(left: 30),

              //   child:Flexible(
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Text(

              //             songName,
              //             maxLines: 1,
              //             overflow: TextOverflow.ellipsis,
              //             style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 16,
              //               color: Color.fromARGB(240, 0, 0, 0),
              //             ),

              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // )
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width -
                        40, // Adjust as needed
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      songName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromARGB(240, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
