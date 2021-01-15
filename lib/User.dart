import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:lyrics_music/LoginWidget.dart';
import 'package:lyrics_music/SongWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<SongInfo> userSongs = List<SongInfo>();

class UserWidget extends StatefulWidget {
  //String title;
  //final bool showLyrics;
  //UserWidget({Key key, this.title}) : super(key: key);

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  //final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  //String data;
  //bool showLyrics;
  //String title;
  //String artist;

  var values = List<String>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //post();
    setState(() {});
  }

  Widget build(BuildContext context) {
    if (!FirebaseAuth.instance.currentUser.isAnonymous)
      return Container(
        color: Colors.black,
        child: FutureBuilder(
            future:
                FlutterAudioQuery().getSongs(sortType: SongSortType.DEFAULT),
            builder: (c, s) {
              List<SongInfo> songs = s.data;
              if (s.hasData)
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('songs')
                        .where('user_id',
                            isEqualTo: FirebaseAuth.instance.currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        userSongs =
                            getUserSongs(query: snapshot.data, songs: songs);
                        return SongWidget(
                          songList: userSongs,
                        );
                      }
                      return Container();
                    });

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
            }),
      );
    return Container(
      color: Colors.black,
      child: Align(
        alignment: Alignment.center,
        child: ButtonTheme(
          height: 80.0,
          minWidth: 200,
          child: RaisedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => LoginWidget()));
            },
            child: const Text('Sign up', style: TextStyle(fontSize: 28)),
            color: Colors.white38,
            textColor: Colors.white,
          ),
        ),
      ),
    );
  }

  List<SongInfo> getUserSongs({QuerySnapshot query, List<SongInfo> songs}) {
    if (songs == null) {
      return [];
    }
    List<SongInfo> a = new List<SongInfo>();

    for (QueryDocumentSnapshot q in query.docs) {
      String song = q['title'];

      for (SongInfo s in songs) {
        if ((s.title).toLowerCase() == song.toLowerCase()) {
          a.add(s);
        }
      }
    }
    return a;
  }
}
