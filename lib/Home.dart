import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int index = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadIndex();
  }

  _loadIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      index = (prefs.getInt('index') ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (index != null && songsI != null)
    return Container(
      color: Colors.black,
      child: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            //List<SongInfo> songs = snapshot.data;
            if (snapshot.hasData) {
              int x = snapshot.data.getInt('index') ?? 0;

              return Container(
                color: Colors.black,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            "Music Lyrics",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 160.0,
                              height: 160.0,
                              child: defaultArt(songsI.elementAt(x)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: AutoSizeText(
                            songsI.elementAt(x).title +
                                " - " +
                                songsI.elementAt(x).artist,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                    ],
                  ),
                ),
              );
            }
            return Container();
          }),
    );
  }
}
