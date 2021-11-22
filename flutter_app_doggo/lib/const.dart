import 'dart:ui';
import "dart:math";
import 'package:firebase_auth/firebase_auth.dart';

import 'tabs_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'person_profile.dart';

final defaultBlueFirst = Color(0xff47659e);
final defaultBlueSecond = Color(0xff789fff);
final defaultOrange = Color(0xffee870d);
final defaultFont = "Roboto";

var gifList = ['assets/popa_korgi.gif', 'assets/popa_korgi2.gif', 'assets/tap_tap_korgi.gif' ];
final random = new Random();
var randomGif = gifList[random.nextInt(gifList.length)];

bool userWalking = false;
List<DocumentSnapshot> myDogs = [];
DocumentReference writeUser;
//PersonProfile personProfile = PersonProfile(FirebaseAuth.instance.currentUser.uid);







