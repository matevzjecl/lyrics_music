import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lyrics_music/User.dart';
import 'Home.dart';
import 'SongList.dart';
import 'LoginWidget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'songwidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool isPlaying = false;
final AudioPlayer player = AudioPlayer();
IconData playBtn = Icons.play_arrow;
final FlutterAudioQuery audioQuery = FlutterAudioQuery();
Future<List<SongInfo>> songInfo;
List<SongInfo> songsI;

Image defaultArt(SongInfo song) {
  if (song.albumArtwork == null) {
    return Image.asset("assets/default.png");
  } else {
    return Image.file(File(song.albumArtwork));
  }
}

String commonWords(String s) {
  if (s.contains("(Official Video)")) {
    s = s.replaceAll("(Official Video)", "");
  }
  return s;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null)
      return MaterialApp(
        title: "Music Lyrics",
        debugShowCheckedModeBanner: false,
        home: MusicApp(),
      );
    return MaterialApp(
      title: "Music Lyrics",
      debugShowCheckedModeBanner: false,
      home: LoginWidget(),
    );
  }
}

class MusicApp extends StatefulWidget {
  //final User user;
  //MusicApp({Key key, this.user}) : super(key: key);
  @override
  _MusicAppState createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  String _path = "";
  int index = 0;
  int _currentIndex = 0;
  List<SongInfo> list;
  final List<Widget> _children = [
    HomeWidget(),
    SongListWidget(),
    UserWidget(),
    null
  ];

  String _queryValue;
  bool _searching = false;
  Duration position = new Duration();
  Duration musicLength = new Duration();
  SearchBar searchBar;
  String displayName;
  bool _repeat = false;
  bool _shuffle = false;

  //bool playing = false;
  Widget slider() {
    return Slider.adaptive(
        activeColor: Colors.white,
        inactiveColor: Colors.grey[350],
        min: 0,
        value: position.inSeconds.toDouble(),
        max: musicLength.inSeconds.toDouble(),
        onChanged: (value) {
          if (!isPlaying) {
            player.play(_path, isLocal: true);
          }
          seekToSec(value.toInt());
        });
  }

  void songsAll() async {
    songsI = await audioQuery.getSongs(sortType: SongSortType.DEFAULT);
  }

  _loadPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _path = (prefs.getString('path') ?? "");
    });
  }

  _loadIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      index = (prefs.getInt('index') ?? 0);
    });
  }

  Future<List<SongInfo>> getSongsFromMemory() async {
    Future<List<SongInfo>> list =
        audioQuery.getSongs(sortType: SongSortType.DEFAULT);
    return list;
    //songInfo = await audioQuery.getSongs(sortType: SongSortType.DEFAULT);
  }

  _playByIndex(int i) async {
    //position = new Duration(seconds: await player.getCurrentPosition());
    //musicLength = new Duration(seconds: await player.getDuration());
    position = new Duration();
    isPlaying = true;
    //player.pause();
    //playBtn = Icons.play_arrow;
    var pref = await SharedPreferences.getInstance();
    await pref.setInt('index', i);
    await pref.setString('path', songsI.elementAt(i).filePath);
    print("index: " + index.toString());
    player.play(songsI.elementAt(i).filePath, isLocal: true);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });*/
    setState(() {
      songsAll();
      _loadIndex();
      _loadPath();
    });

    //songInfo = getSongsFromMemory();
    isPlaying = false;
    //player.play("file://${_path}", isLocal: true);
    player.stop();

    setState(() {
      if (FirebaseAuth.instance.currentUser.displayName != null) {
        displayName = FirebaseAuth.instance.currentUser.displayName;
      } else {
        displayName = "Guest";
      }
    });
    //player.getCurrentPosition().then((value) => position = value;
    player.onDurationChanged
        .listen((Duration p) => {setState(() => musicLength = p)});
    player.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        position = p;
        if (position.inSeconds == musicLength.inSeconds) {
          //_loadIndex();
          if (_repeat) {
            _playByIndex(index - 1);
            _repeat = false;
          } else {
            _playByIndex(index + 1);
          }
        }
      });
    });

    //player.seek
    setState(() {
      searchBar = new SearchBar(
          inBar: false,
          setState: setState,
          onSubmitted: onSubmitted,
          buildDefaultAppBar: buildAppBar);
    });
  }

  void onSubmitted(String value) {
    setState(() {
      _queryValue = value;
      _searching = true;
    });

    //songList = searchSongs(query: value);
  }

  Widget listWidget() {
    return FutureBuilder(
        future: FlutterAudioQuery().getSongs(sortType: SongSortType.DEFAULT),
        builder: (context, snapshot) {
          List<SongInfo> songs = userSongs;
          //print("qv:" + queryValue);
          List<SongInfo> songList = searchSongs(
              query: _queryValue,
              song: (_currentIndex == 2) ? songs : snapshot.data);
          if (snapshot.hasData)
            return Container(
              color: Colors.black,
              child: SongWidget(songList: songList),
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
        });
  }

  List<SongInfo> searchSongs({String query, List<SongInfo> song}) {
    if (song == null) {
      return [];
    }
    List<SongInfo> a = new List<SongInfo>();
    for (int i = 0; i < song.length; i++) {
      if ((song.elementAt(i).title).toLowerCase().contains(query)) {
        a.add(song.elementAt(i));
      }
    }
    return a;
  }

  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    player.seek(newPos);
  }

  void _play() async {
    _loadPath();
    if (!isPlaying) {
      player.play(_path, isLocal: true);
      setState(() {
        playBtn = Icons.pause;
        isPlaying = true;
      });
    } else {
      player.pause();
      setState(() {
        playBtn = Icons.play_arrow;
        isPlaying = false;
      });
    }
  }

  void onTabTapped(int index) async {
    if (index == 3) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => LoginWidget()));
    }
    setState(() {
      _currentIndex = index;
      _searching = false;
    });
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text("Music Lyrics"),
      actions: [searchBar.getSearchAction(context)],
    );
  }

  Widget bottomPanel() {
    return Container(
      color: Colors.black,
      child: Column(children: <Widget>[
        //Padding(
        //padding: EdgeInsets.symmetric(horizontal: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                  "${position.inMinutes}:${position.inSeconds.remainder(60)}",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.right),
            ),
            Expanded(flex: 9, child: slider()),
            Expanded(
              flex: 1,
              child: Text(
                "${musicLength.inMinutes}:${musicLength.inSeconds.remainder(60)}",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        //),
        Container(
          //padding: EdgeInsets.symmetric(vertical: 16),
          /*child: FutureBuilder(
              future:
                  FlutterAudioQuery().getSongs(sortType: SongSortType.DEFAULT),
              builder: (context, snapshot) {
                List<SongInfo> songs = snapshot.data;
                if (snapshot.hasData)*/
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    color: Colors.white38,
                    size: 40,
                  ),
                  onPressed: () async {
                    //_loadIndex();

                    player.play(songsI.elementAt(index - 1).filePath);
                    index--;
                    //saveIntInLocalMemory('index', index);
                    var pref = await SharedPreferences.getInstance();
                    pref.setInt('index', index);
                    pref.setString('path',
                        "file://${songsI.elementAt(index - 1).filePath}");
                    if (!isPlaying) {
                      playBtn = Icons.pause;
                    }
                  },
                ),
              ),
              Center(
                child: IconButton(
                  onPressed: _play,
                  padding: const EdgeInsets.all(0.0),
                  icon: Icon(
                    playBtn,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              Center(
                child: IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    color: Colors.white38,
                    size: 40,
                  ),
                  onPressed: () async {
                    //_loadIndex();
                    player.play(songsI.elementAt(index + 1).filePath);
                    index++;
                    //saveIntInLocalMemory('index', index);
                    var pref = await SharedPreferences.getInstance();
                    pref.setInt('index', index);
                    pref.setString('path',
                        "file://${songsI.elementAt(index - 1).filePath}");
                    if (!isPlaying) {
                      playBtn = Icons.pause;
                    }
                  },
                ),
              ),
            ],
            //);
            /*return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          color: Colors.grey,
                          size: 40,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    Center(
                      child: IconButton(
                        onPressed: _play,
                        padding: const EdgeInsets.all(0.0),
                        icon: Icon(
                          playBtn,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                    Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: Colors.grey,
                          size: 40,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                );*/
            //}
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: IconButton(
                icon: Icon(Icons.shuffle),
                onPressed: () {
                  if (_shuffle) {
                    setState(() {
                      _shuffle = false;
                      songsI.shuffle();
                    });
                  } else {
                    setState(() {
                      _shuffle = true;
                      songsAll();
                    });
                  }
                  print(_shuffle);
                },
                color: _shuffle ? Colors.white : Colors.grey,
                iconSize: 30.0,
              ),
            ),
            Expanded(
              flex: 4,
              child: IconButton(
                  icon: Icon(Icons.repeat),
                  iconSize: 30.0,
                  color: _repeat ? Colors.white : Colors.grey,
                  onPressed: () {
                    print(_repeat);
                    if (_repeat) {
                      setState(() {
                        _repeat = false;
                      });
                    } else {
                      setState(() {
                        _repeat = true;
                      });
                    }
                  }),
            )
          ],
        )
      ]),
    );
  }

  Widget body() {
    if (_searching) {
      return listWidget();
    } else {
      //if (_currentIndex != 3) {
      return _children[_currentIndex];
      //} else {
      //  return _children[3];
      //}
    }
  }

  Widget navigationBar() {
    return SizedBox(
      height: 56,
      child: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(11, 11, 11, 1),
        unselectedItemColor: Colors.white38,
        selectedItemColor: Colors.white,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.home),
            label: "Home",
          ),
          new BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.list),
            label: "List",
          ),
          new BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.person),
            label: displayName,
          ),
          new BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.logout),
            label: "Logout",
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: searchBar.build(context),
      /*AppBar(
        title: Text("Music Lyrics"),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                onTabTapped(2);
              })
        ],
      ),*/
      body: Container(
        //height: 100.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 4,
                //eight: MediaQuery.of(context).size.height * 0.65,
                child: body()),
            Expanded(
              flex: 2,
              //height: 140.0,
              child: bottomPanel(),
            )
          ],
        ),
      ),
      bottomNavigationBar: navigationBar(),
    );
  }
}

//var audioManagerInstance = AudioManager.instance;
//PlayMode playMode = audioManagerInstance.playMode;
