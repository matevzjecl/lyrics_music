import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'SongWidget.dart';

//import 'package:flute_music_player/flute_music_player.dart';

class SongListWidget extends StatelessWidget {
//  @override
//  _SongListWidgetState createState() => _SongListWidgetState(/*this.path*/);
//}

//class _SongListWidgetState extends State<SongListWidget> {
  //ArtistInfo artist;

  /*@override
  void initState() {
    // TODO: implement initState

    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: FutureBuilder(
        future: FlutterAudioQuery().getSongs(sortType: SongSortType.DEFAULT),
        builder: (context, snapshot) {
          List<SongInfo> songs = snapshot.data;
          if (snapshot.hasData)
            return Container(
              color: Colors.black,
              child: SongWidget(songList: songs),
            );
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Loading....",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
