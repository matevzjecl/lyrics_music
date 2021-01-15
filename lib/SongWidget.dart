import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'LyricsText.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SongWidget extends StatelessWidget {
  final List<SongInfo> songList;
  //final bool user;
  SongWidget({@required this.songList});
  @override
  Widget build(BuildContext context) {
    if (songList != null)
      return ListView.builder(
          itemCount: songList.length,
          itemBuilder: (context, songIndex) {
            SongInfo song = songList[songIndex];
            Color color = Colors.black;
            //if (song.displayName.contains(".mp3"))
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 2.0, color: Colors.grey),
                ),
                //color: Colors.white,
              ),
              child: Card(
                color: color,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          child: Container(
                              width: 100.0,
                              height: 100.0,
                              child: defaultArt(song)),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        //width: MediaQuery.of(context).size.width * 0.6,
                        //padding: const EdgeInsets.all(12.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  color = Colors.white;
                                  player.play("file://${song.filePath}",
                                      isLocal: true);
                                  playBtn = Icons.pause;
                                  //index = songIndex;
                                  //path = "file://${song.filePath}";
                                  var pref =
                                      await SharedPreferences.getInstance();
                                  print(songIndex);
                                  await pref.setInt('index', songIndex);
                                  await pref.setString(
                                      'path', "file://${song.filePath}");
                                  //saveIntInLocalMemory('index', index);
                                  isPlaying = true;
                                },
                                onLongPress: () async {
                                  var ref = await FirebaseFirestore.instance
                                      .collection('songs')
                                      .where('title', isEqualTo: song.title)
                                      .where('artist', isEqualTo: song.artist)
                                      .get();
                                  String id = ref.docs[0].id;
                                  await FirebaseFirestore.instance
                                      .collection('songs')
                                      .doc(id)
                                      .delete();
                                },
                                //child: Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Text(commonWords(song.title),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    if (song.year != null)
                                      Text("Release Year: ${song.year}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500)),
                                    if (song.artist != null)
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: Text("Artist: ${song.artist}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    if (song.composer != null)
                                      Text("Composer: ${song.composer}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500)),
                                    Text(
                                        "Duration: ${parseToMinutesSeconds(int.parse(song.duration))} min",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                //),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('songs')
                                .where('title', isEqualTo: song.title)
                                .where('artist', isEqualTo: song.artist)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                //print(snapshot.data.docs);
                                //String lyrics = snapshot.data.docs[0]["lyrics"];
                                final list = snapshot.data.docs;
                                for (dynamic q in list) {
                                  String lyrics = q['lyrics'];
                                  //if (song.title == q['title'])
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.file_copy,
                                            color: Colors.white60,
                                          ),
                                          iconSize: 30.0,
                                          onPressed: () {
                                            lyrics =
                                                lyrics.replaceAll('\\n', '\n');
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        LyricsTextWidget(
                                                          title: song.title,
                                                          artist: song.artist,
                                                          lyrics: lyrics,
                                                          mode: 0,
                                                        )));
                                          },
                                        ),
                                      ),
                                      Expanded(
                                          child:
                                              !FirebaseAuth.instance.currentUser
                                                      .isAnonymous
                                                  ? IconButton(
                                                      icon: Icon(Icons.edit),
                                                      color: Colors.white60,
                                                      onPressed: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    LyricsTextWidget(
                                                                      title: song
                                                                          .title,
                                                                      artist: song
                                                                          .artist,
                                                                      lyrics: lyrics.replaceAll(
                                                                          '\\n',
                                                                          '\n'),
                                                                      mode: 1,
                                                                    )));
                                                      },
                                                    )
                                                  : Container())
                                    ],
                                  );
                                }
                              }
                              if (!FirebaseAuth
                                  .instance.currentUser.isAnonymous) {
                                return IconButton(
                                  icon: Icon(Icons.add),
                                  iconSize: 35.0,
                                  color: Colors.white60,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                LyricsTextWidget(
                                                  title: song.title,
                                                  artist: song.artist,
                                                  mode: 2,
                                                )));
                                  },
                                );
                              }
                              return Container();
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            );
            // ),
          });
    return CircularProgressIndicator();
  }

  static String parseToMinutesSeconds(int ms) {
    String data;
    Duration duration = Duration(milliseconds: ms);

    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds) - (minutes * 60);

    data = minutes.toString() + ":";
    if (seconds <= 9) data += "0";

    data += seconds.toString();
    return data;
  }
}
