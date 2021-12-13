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
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'const.dart';

class PersonProfile extends StatefulWidget {
  final String _currentUid;

  PersonProfile(String uid) : _currentUid = uid;

  @override
  _PersonProfileState createState() => _PersonProfileState();
}

class _PersonProfileState extends State<PersonProfile> {
  String _personImageURL;
  String _personName = ' ';

  List<Widget> _dogs = [];

  void initState() {
    super.initState();
    _fillFields().then((value) => null);

  }

  updateDogs() async
  {

    _dogs = _fillListDogs(myDogs);
  }

  Future _fillFields() async {
    print("INIT STATE!!!!");
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget._currentUid)
        .get();

    String personName = user.get('name');

    String personImageURL = '';

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/' + widget._currentUid + '/profile');

    await storageReference
        .getDownloadURL()
        .then((fileURL) => setState(() => personImageURL = fileURL));

    bool isException = true;
    QuerySnapshot dogsCollection;
    while(isException) {
      try {
        dogsCollection = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget._currentUid)
            .collection('dogs')
            .get();
        isException = false;
      }
      on Exception catch (e) {
        print("wtf");
      }
    }


    List<DocumentSnapshot> dogsList = dogsCollection.docs;
    myDogs = dogsCollection.docs;
    List<Widget> dogs = [];

    if(mounted) {
      setState(() {
        print("SET STATE!!!!");
        dogs = _fillListDogs(dogsList);
        _personImageURL = personImageURL;
        _personName = personName;
        _dogs = dogs;
      });
    }
  }

  List<Widget> _fillListDogs(List<DocumentSnapshot> dogsList) {
    List<Widget> dogs = [];

    dogsList.forEach((element) async {
      String dogName = element.get('name');

      String dogImageURL = '';
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'users/' + widget._currentUid + '/dogs/' + element.id + '/profile');

      bool isException = true;
      while(isException) {
        try {
          await storageReference
              .getDownloadURL()
              .then((fileURL) => setState(() => dogImageURL = fileURL));

          isException = false;
        }
        on Exception catch (e) {
          print("wtf");
        }
      }

        String dogBreed = element.get('breed');
        String dogSex = element.get('sex');
        String dogAge = element.get('age').toString();
        bool _dogIsWalking = element.get('isWalking');

        dogs.add(
          GestureDetector(
            onTap: () { Navigator.pushNamed(context, '/dogProfile/${widget._currentUid}/${element.id}');},
            child:
          Row(
            children: [
              Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(dogImageURL),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              SizedBox(width: 20),
              Container(
                width: 180,
                height: 69,
                child: Stack(
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                              children: [
                                Text(
                                  dogName,
                                  style: TextStyle(
                                    color: Color(0xff48659e),
                                    fontSize: 18,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.12,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Container(
                                  // alignment: Alignment.center,
                                  margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
                                  child: Icon(Ionicons.ios_paw,
                                      color: Color(_dogIsWalking ? 0xff4f9567 : 0xffb60040),
                                      size: 20
                                  ),
                                )
                              ]
                          ),
                          SizedBox(height: 6),
                          Flexible(
                              child: Text(
                                dogBreed,
                                style: TextStyle(
                                  color: Color(0xff48659e),
                                  fontSize: 15,
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.98,
                                ),
                              )
                          ),
                          Text(
                            (dogSex == "Male" ? "мальчик, " : "девочка, ") +
                                dogAge +
                                " лет",
                            style: TextStyle(
                              color: Color(0xff48659e),
                              fontSize: 15,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.98,
                            ),
                          )
                        ]
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));

    });
    setState(() {

    });
    return dogs;
  }

  void _onOpenSettingsButtonPressed() {
    setState(() {
      Navigator.pushNamed(context, '/humanSettings/${widget._currentUid}/dog');
    });
  }

  void _onChatButtonPressed() {
    setState(() {
      //переход к окну с чатами
    });
  }

  void _onMapButtonPressed() {
    setState(() {
      Navigator.pushNamed(
          context,
          '/map/' + widget._currentUid,); // изменил, т.к. мы задаем в итоге новый виджет карты,
      // у которой уже нет ID пользователя
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            fit: StackFit.loose,
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height,),
              Positioned(
                // bottom: 10,
                child: Container(
                  alignment: Alignment.topCenter,
                  height: _personImageURL == null
                      ? MediaQuery.of(context).size.height * 0.45
                      : MediaQuery.of(context).size.height * 0.65, // как раз таки относительное взятие размеров окна
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _personImageURL == null
                          ? AssetImage(randomGif)
                          : CachedNetworkImageProvider(
                          _personImageURL), // придумать, что делать, пока фото грузится
                      // (может как-то использовать анимацию загрузки)
                      fit: _personImageURL == null ? BoxFit.none : BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2.2,
                child: Container(
                  child:
                  /* LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Column(mainAxisAlignment: MainAxisAlignment.end, children: [*/
                  //  Container(
                  //  margin: EdgeInsets.fromLTRB(40, 0, 0, 50),
                  //    child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //alignment: Alignment.bottomCenter,
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
                                      Text(_personName,
                                          style: TextStyle(
                                            color: Color(0xff47659e),
                                            fontSize: 28,
                                            fontFamily: "Roboto",
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.96,
                                            // ),
                                          )),
                                      /* Container(
                            // alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(0, 0, , 0),
                            child: IconButton(
                                icon: const Icon(
                                    FluentIcons.settings_24_regular,
                                    color: Color(0xff48659e)),
                                iconSize: 40,
                                onPressed: _onOpenSettingsButtonPressed),
                          )*/ ///////////// убрать в отдельную колонку видимо хз
                                      /* Positioned(
                      left: 60,
                      top: 75,*/
                                      //child:
                                      Row(children: [
                                        Container(
                                          // alignment: Alignment.center,
                                          margin: EdgeInsets.fromLTRB(0, 0, 0, 2.5),
                                          child: Icon(Ionicons.ios_paw,
                                              color: Color(userWalking
                                                  ? 0xff4f9567
                                                  : 0xffb60040),
                                              size: 16),
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          userWalking ? "на прогулке" : "сидит дома",
                                          style: TextStyle(
                                            color: Color(userWalking
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
                            Container(
                              // alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: IconButton(
                                  icon: const Icon(FluentIcons.settings_24_regular,
                                      color: Color(0xff48659e)),
                                  iconSize: 40,
                                  onPressed: _onOpenSettingsButtonPressed),
                            )
                          ]),
                      /*Positioned(
                      left: 42,
                      top: 130,*/
                      //child:
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: Text(
                          "Питомцы",
                          style: TextStyle(
                            color: Color(0xff47659e),
                            fontSize: 23,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.26,
                          ),
                        ),
                      ),
                      //),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _dogs.toList(),
                        ),
                      ),
                    ],
                  ),
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
    // })),
    //]));
  }
}
