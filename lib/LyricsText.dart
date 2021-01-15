import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class LyricsTextWidget extends StatelessWidget {
  final String title;
  final String artist;
  String lyrics;
  final int mode;
  LyricsTextWidget({this.title, this.artist, this.lyrics, @required this.mode});

  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: _menu(context),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.black,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 10, left: 5, right: 10),
                child: _textBox(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menu(BuildContext context) {
    switch (mode) {
      case 0:
        return AppBar(
            backgroundColor: Colors.black,
            title: Text(
              artist + " - " + title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ));
        break;
      case 1:
        return AppBar(
            backgroundColor: Colors.black,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 6,
                  child: AutoSizeText(
                    artist + " - " + title,
                    textAlign: TextAlign.left,
                    minFontSize: 20.0,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.white,
                        //fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () async {
                        var ref = await FirebaseFirestore.instance
                            .collection('songs')
                            .where('title', isEqualTo: title)
                            .where('artist', isEqualTo: artist)
                            .get();
                        String id = ref.docs[0].id;
                        await FirebaseFirestore.instance
                            .collection('songs')
                            .doc(id)
                            .update({'lyrics': lyrics});
                        Navigator.of(context).pop(true);
                      }),
                )
              ],
            ));
        break;
      case 2:
        return AppBar(
            centerTitle: false,
            titleSpacing: 0.0,
            backgroundColor: Colors.black,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AutoSizeText(
                  artist + " - " + title,
                  textAlign: TextAlign.left,
                  minFontSize: 12.0,
                  maxFontSize: 16.0,
                  maxLines: 2,
                  style: TextStyle(
                      color: Colors.white,
                      //fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('songs').add({
                        'title': title,
                        'artist': artist,
                        'lyrics': lyrics,
                        'user_id': FirebaseAuth.instance.currentUser.uid
                      });
                      Navigator.of(context).pop(true);
                    })
              ],
            ));
        break;
    }
  }

  Widget _textBox() {
    switch (mode) {
      case 0:
        return AutoSizeText(
          lyrics,
          //song.replaceAll('\\n', '\n'),
          textAlign: TextAlign.center,
          //softWrap: false,
          style: TextStyle(
            letterSpacing: 1.3,
            height: 1.3,
            color: Colors.white,
            fontSize: 18.0,
          ),
        );
        break;
      case 1:
        return Container(
          child: TextFormField(
            decoration: InputDecoration(
                hintText: lyrics, contentPadding: const EdgeInsets.all(20)),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.multiline,
            autofocus: true,
            initialValue: lyrics,
            onChanged: (text) {
              lyrics = text;
            },
            maxLines: null,
            style: TextStyle(
              letterSpacing: 1.3,
              height: 1.3,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        );
        break;
      case 2:
        return Container(
          child: TextFormField(
            decoration: InputDecoration(
                hintText: lyrics, contentPadding: const EdgeInsets.all(20)),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.multiline,
            autofocus: true,
            onChanged: (text) {
              lyrics = text;
            },
            maxLines: null,
            style: TextStyle(
              letterSpacing: 1.3,
              height: 1.3,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        );
    }
    return Container();
  }
}
