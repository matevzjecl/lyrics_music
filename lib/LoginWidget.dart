import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lyrics_music/Home.dart';
import 'package:lyrics_music/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _formKey = new GlobalKey<FormState>();
  var _passwordController = TextEditingController();
  bool signUp = true;
  String email = "";
  String password = "";
  User user;

  Widget _buildEmail() {
    return TextFormField(
      onChanged: (val) {
        setState(() {
          email = val;
        });
      },
      validator: (value) => !isEmail(value) ? "Email not found" : null,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(1),
          child: Icon(
            Icons.email,
            color: Colors.white,
          ),
        ),
        fillColor: Colors.white,
        hintText: "Email Address",
        hintStyle: TextStyle(
          color: Colors.white38,
        ),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });*/
    _currentUser();
  }

  _currentUser() async {
    user = _auth.currentUser;
  }

  Widget _buildPassword() {
    return TextFormField(
      onChanged: (val) {
        if (!signUp) {
          setState(() {
            password = val;
          });
        }
      },
      obscureText: true,
      controller: _passwordController,
      validator: (value) =>
          value.length <= 8 ? "Password must be more than 8 characters" : null,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(1),
          child: Icon(
            Icons.lock,
            color: Colors.white,
          ),
        ),
        fillColor: Colors.white,
        hintText: "Password",
        hintStyle: TextStyle(
          color: Colors.white38,
        ),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _buildConfirmPassword() {
    if (signUp)
      return TextFormField(
        onChanged: (val) {
          setState(() {
            password = val;
          });
        },
        obscureText: true,
        validator: (value) => value.isEmpty ||
                (value.isNotEmpty && value != _passwordController.text)
            ? "Password doesn't match"
            : null,
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(1),
            child: Icon(
              Icons.lock,
              color: Colors.white,
            ),
          ),
          fillColor: Colors.white,
          hintText: "Repeat Password",
          hintStyle: TextStyle(
            color: Colors.white38,
          ),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      );
    return Container();
  }

  Widget _buildSignUpButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 43),
      child: InkWell(
        child: const Icon(
          Icons.arrow_right,
          color: Colors.white,
          size: 50.0,
        ),
        //elevation: 0.4,
        onTap: () async {
          if (signUp) {
            var result = await _auth.createUserWithEmailAndPassword(
                email: email, password: password);
            if (result == null) {
              print("error");
            } else {
              result.user.updateProfile(
                  displayName: email.substring(0, email.indexOf('@')));
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => MusicApp(),
              ));
            }
          } else {
            var result = await _auth.signInWithEmailAndPassword(
                email: email, password: password);
            if (result != null) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => MusicApp()));
            }
          }
        },
      ),
    );
  }

  Widget _buildGuest() {
    return Container(
      margin: const EdgeInsets.only(top: 43),
      child: InkWell(
        child: const Text(
          "Continue as Guest",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        //elevation: 0.4,
        onTap: () async {
          /*dynamic result = await _auth.signInGuest();
          if (result == null) {
            print("abc");
          } else {*/
          //_validateAndSubmit();
          //await Firebase.initializeApp();
          await _auth.signInAnonymously();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => MusicApp(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitch() {
    if (!signUp)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Sign In",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: () {
              /*Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignupWidget()));*/
              setState(() {
                signUp = true;
              });
            },
            child: Text(
              "Sign Up",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: () {
            /*Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignupWidget()));*/
            setState(() {
              signUp = false;
            });
          },
          child: Text(
            "Sign In",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  bool isEmail(String value) {
    String regex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(regex);

    return value.isNotEmpty && regExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 43.0),
          child: Form(
            key: _formKey,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/icon.png"),
                          //fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(children: <Widget>[
                      _buildSwitch(),
                      _buildEmail(),
                      _buildPassword(),
                      _buildConfirmPassword(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_buildGuest(), _buildSignUpButton(context)],
                      ),
                    ]),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
