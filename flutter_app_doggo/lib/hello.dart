import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register.dart';
import 'main.dart';
import 'input_phone_number.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class WelcomeWindow extends StatefulWidget {
  @override
  _WelcomeWindowState createState() => _WelcomeWindowState();
}

class _WelcomeWindowState extends State<WelcomeWindow> {

  @override
  void initState() {
    //_autoAuth();
    // TODO: implement initState
    super.initState();
  }


  void _autoAuth()
  {
    // FirebaseAuth.instance
    //     .authStateChanges()
    //     .listen((User user) {
    //   if (user == null) {
    //     print('\nUser is currently signed out!\n');
    //   } else {
    //     print('\nUser is signed in!\n');
    //   }
    // });
    //
    try {
      String uid = FirebaseAuth.instance.currentUser.uid;
        Navigator.pushNamedAndRemoveUntil(
            context, '/map/$uid', (route) => false);

    }
    catch(e)
    {
      print("${FirebaseAuth.instance.currentUser.uid} ошибка авто аутентификации \n");
    }

  }

  void _onLogInButtonPressed() {
    setState(() {
      Navigator.of(context).push(SwipeablePageRoute(
        builder: (BuildContext context) => InputPhoneNumberWindow(),
      ));
    });
  }

  void _onRegisterButtonPressed() {
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterWindow()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 150, 0.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x59c2d1f5),
                            blurRadius: 7,
                            offset: Offset(4, 4),
                          ),
                          BoxShadow(
                            color: Color(0xffffffff),
                            blurRadius: 4,
                            offset: Offset(-4, -4),
                          ),
                        ],
                        color: Color(0xfffbfbfb),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Ionicons.ios_paw, color: Color(0xff789fff), size: 72),
                          Text(
                            "DOGGO",
                            style: TextStyle(
                              color: Color(0xff789fff),
                              fontSize: 14,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.98,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 128.67),
                    Text(
                      "Добро пожаловать!",
                      style: TextStyle(
                        color: Color(0xff48659e),
                        fontSize: 20,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 18.67),
                    SizedBox(
                      width: 300,
                      height: 55,
                      child:
                      ElevatedButton(
                        onPressed: () {
                          _onLogInButtonPressed();
                        },
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(
                                Color(0xffee870d)),
                            foregroundColor:
                            MaterialStateProperty.all(
                              Color(0xffee870d),
                            ),
                            overlayColor: MaterialStateProperty.all(
                                Color(0xffee870d)),
                            shadowColor: MaterialStateProperty.all(
                                Color(0xffee870d)),
                            //elevation: MaterialStateProperty.all(20),
                            // side: MaterialStateProperty.all(BorderSide(width: 155, style: BorderStyle.none, color: Color(0xff789fff))),
                            enableFeedback: false,
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(22),
                                    side: BorderSide(
                                        color: Color(0x59c2d1f5))))
                          //shape: MaterialStateProperty.all(O)
                        ),
                        child: Text(
                          "ВХОД",
                          style: TextStyle(
                            color: Color(0xfffbfbfb),
                            fontSize: 18,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.67),
                    SizedBox(
                      width: 300,
                      height: 55,
                      child:
                      ElevatedButton(
                        onPressed: () {
                          _onRegisterButtonPressed();
                        },
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(
                                Color(0xff789fff)),
                            foregroundColor:
                            MaterialStateProperty.all(
                              Color(0xff789fff),
                            ),
                            overlayColor: MaterialStateProperty.all(
                                Color(0xff789fff)),
                            shadowColor: MaterialStateProperty.all(
                                Color(0xff789fff)),
                            //elevation: MaterialStateProperty.all(20),
                            // side: MaterialStateProperty.all(BorderSide(width: 155, style: BorderStyle.none, color: Color(0xff789fff))),
                            enableFeedback: false,
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(22),
                                    side: BorderSide(
                                        color: Color(0x59c2d1f5))))
                          //shape: MaterialStateProperty.all(O)
                        ),
                        child: Text(
                          "РЕГИСТРАЦИЯ",
                          style: TextStyle(
                            color: Color(0xfffbfbfb),
                            fontSize: 18,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}