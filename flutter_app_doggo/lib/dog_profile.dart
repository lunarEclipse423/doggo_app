import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/painting/box_decoration.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'const.dart';

class DogProfile extends StatefulWidget {
  final String _currentUid;
  final String _dogName;
  DogProfile(String uid, String uidDog):_currentUid = uid, _dogName = uidDog;
  @override
  _DogProfileState createState() => _DogProfileState();
}

class _DogProfileState extends State<DogProfile> {

  String _name = "";
  String _dogImageURL;
  String _sex = "";
  String _breed = "";
  String _age = "";
  String _description = "";
  bool _isWalking = false;

  void initState() {
    super.initState();
    _getDogData();
  }

  void _getDogData() async
  {
    final DocumentSnapshot dog = await FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid)
        .collection('dogs')
        .doc(widget._dogName).get();
    if(mounted) {
      _name = dog.get('name');
      _sex = dog.get('sex') == 'Female' ? 'Девочка' : 'Мальчик';
      _breed = dog.get('breed');
      _age = dog.get('age').toString();
      _description = dog.get('description');
      _isWalking = dog.get('isWalking');
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('users/' + widget._currentUid + '/dogs/' +
          widget._dogName
          + '/profile');
      await storageReference.getDownloadURL().then((loc) => setState(() => _dogImageURL = loc));
    }

  }

  void _onGoToPersonPressed() {
    setState(() {
      if (widget._currentUid == FirebaseAuth.instance.currentUser.uid) {
        Navigator.pushNamed(context, '/personProfile/${widget._currentUid}');
      }
      else {
        Navigator.pushNamed(context, '/personProfileView/${widget._currentUid}');
      }
    });
  }

  void _onOpenSettingsButtonPressed()
  {
    setState(() {
      Navigator.pushNamed(context, '/dogSettings/${widget._currentUid}/${widget._dogName}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            //clipBehavior: Clip.none,
            fit: StackFit.loose,
          //  alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
             SizedBox(height: MediaQuery.of(context).size.height,),
          Container(
            clipBehavior: Clip.hardEdge,
            height: _dogImageURL == null
                ? MediaQuery.of(context).size.height * 0.45
                : MediaQuery.of(context).size.height *
                    0.6, // как раз таки относительное взятие размеров окна
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _dogImageURL == null
                    ? AssetImage(randomGif)
                    : // придумать, что делать, пока фото грузится
                    CachedNetworkImageProvider(_dogImageURL),
                fit: _dogImageURL == null ? BoxFit.none : BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2.2,
            child:
            Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 40),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_name,
                                        style: TextStyle(
                                          color: Color(0xff47659e),
                                          fontSize: 28,
                                          fontFamily: "Roboto",
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.96,
                                          // ),
                                        )),
                                    Row(children: [
                                      Container(
                                        // alignment: Alignment.center,
                                        margin:
                                            EdgeInsets.fromLTRB(0, 0, 0, 2.5),
                                        child: Icon(Ionicons.ios_paw,
                                                  color: Color(_isWalking
                                                      ? 0xff4f9567
                                                      : 0xffb60040),
                                            size: 16),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        _isWalking ?
                                        "на прогулке" : "сидит дома",
                                        style: TextStyle(
                                           color: Color(_isWalking
                                                    ? 0xff4f9567
                                                    : 0xffb60040),
                                          fontSize: 12,
                                          fontFamily: "Roboto",
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.84,
                                        ),
                                        //   ),
                                      ),
                                    ]),
                                  ])),
                          widget._currentUid ==
                                  FirebaseAuth.instance.currentUser.uid
                              ?
                          IconButton(
                                      icon: const Icon(
                                          FluentIcons.settings_24_regular,
                                          color: Color(0xff48659e)),
                                      iconSize: 40,
                                      onPressed: _onOpenSettingsButtonPressed)
                              : Container(),
                        ]),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child:
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(21),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xffffffff),
                                    blurRadius: 7,
                                    offset: Offset(-4, -4),
                                  ),
                                  BoxShadow(
                                    color: Color(0x3f000000),
                                    blurRadius: 10,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                                color: Color(0xfffbfbfb),
                              ),
                              child: Container(
                                child: Center(
                                    child: Icon(Ionicons.ios_paw,
                                        size: 35,
                                        color: Color(0xff48659e))),
                              ),
                            ),
                            ),
                            SizedBox(
                              width: 10,
                            ),

                                Flexible(
                                  child: Text(
                                    _breed, //!!!!!!!!!!!!!!!! тут должна быть порода из БД
                                    style: TextStyle(
                                      color: Color(0xff47659e),
                                      fontSize: 18,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.26,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(21),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xffffffff),
                                    blurRadius: 7,
                                    offset: Offset(-4, -4),
                                  ),
                                  BoxShadow(
                                    color: Color(0x3f000000),
                                    blurRadius: 10,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                                color: Color(0xfffbfbfb),
                              ),
                              child: Container(
                                  child: Stack(children: [
                                Positioned(
                                    top: 10,
                                    right: 17,
                                    child: Container(
                                        child: Icon(Boxicons.bx_female_sign,
                                            size: 23,
                                            color: Color(0xff48659e)))),
                                Positioned(
                                    top: 10,
                                    left: 17,
                                    child: Transform.rotate(
                                        angle: -0.79,
                                        child: Icon(Boxicons.bx_male_sign,
                                            size: 23,
                                            color: Color(0xff48659e))))
                              ], overflow: Overflow.visible)),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          Text(
                            _sex, //!!!!!!!!!!!!!!!! тут должен быть пол из БД
                            style: TextStyle(
                              color: Color(0xff47659e),
                              fontSize: 18,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.26,
                            ),
                          ),
                          Text(
                            _age, //!!!!!!!!!!!!!!!! тут должен быть возраст из БД
                            style: TextStyle(
                              color: Color(0xff47659e),
                              fontSize: 18,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.26,
                            ),
                          ),
                              ]),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.15,
                      height: 80,
                      margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Text(
                        _description,
                        style: TextStyle(
                          color: Color(0xff48659e),
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.26,
                        ),
                      ),
                    ),
              widget._currentUid ==
                  FirebaseAuth.instance.currentUser.uid
                  ?
              Container()
                  :
                  Container(
                    margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                    width: MediaQuery.of(context).size.width / 1.15,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onGoToPersonPressed,
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Color(0xff789fff)),
                          foregroundColor: MaterialStateProperty.all(
                            Color(0xff789fff),
                          ),
                          overlayColor:
                          MaterialStateProperty.all(Color(0xff789fff)),
                          shadowColor: MaterialStateProperty.all(Color(0xff789fff)),
                          //elevation: MaterialStateProperty.all(20),
                          side: MaterialStateProperty.all(BorderSide(
                              style: BorderStyle.none, color: Color(0xff789fff))),
                          enableFeedback: false,
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  side: BorderSide(color: Color(0xff789fff))))
                        //shape: MaterialStateProperty.all(O)
                      ),
                      child: Text(
                        "Перейти к хозяину",
                        style: TextStyle(
                          color: Color(0xfffbfbfb),
                          fontSize: 20,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  ]),
              height: MediaQuery.of(context).size.height *
                  0.55, // высота блока информации в профиле
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                color: Color(0xfffbfbfb),
              ),
            ),
          ),
        ]));
  }
}
