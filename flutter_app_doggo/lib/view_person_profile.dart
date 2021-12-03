import 'package:cached_network_image/cached_network_image.dart';
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
import 'services/database.dart';
import 'views/chat.dart';
import 'const.dart';

class PersonProfileView extends StatefulWidget {
  final String _currentUid;

  PersonProfileView({String uid}) : _currentUid = uid;

  @override
  _PersonProfileViewState createState() => _PersonProfileViewState();
}

class _PersonProfileViewState extends State<PersonProfileView> {
  String _personImageURL;
  String _personName = ' ';
  String _myName = ' ';
  bool _isWalking = false;

  List<Widget> _dogs = [];

  void initState() {
    super.initState();

    _fillFields();
  }

  void _fillFields() async {
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid)
        .get();
    DocumentSnapshot mySnap = await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    String myName = mySnap.get('name');
    String personName = user.get('name');
    bool isWalking = user.get('isWalking');

    String personImageURL = '';

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/' + widget._currentUid + '/profile');

    await storageReference.getDownloadURL().then((fileURL) => setState(() => personImageURL = fileURL));

    QuerySnapshot dogsCollection = await FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid)
        .collection('dogs')
        .get();

    List<DocumentSnapshot> dogsList = dogsCollection.docs;

    List<Widget> dogs = _fillListDogs(dogsList);

    setState(() {
      _myName = myName;
      _personImageURL = personImageURL;
      _personName = personName;
      _isWalking = isWalking;
      _dogs = dogs;
    });
  }

  List<Widget> _fillListDogs(List<DocumentSnapshot> dogsList) {
    List<Widget> dogs = [];

    dogsList.forEach((element) async {
      String dogName = element.get('name');

      String dogImageURL = '';
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('users/' + widget._currentUid + '/dogs/'
          + dogName
          + '/profile');

      await storageReference.getDownloadURL().then((fileURL) => setState(() => dogImageURL = fileURL));

      String dogBreed = element.get('breed');
      String dogSex = element.get('sex');
      String dogAge = element.get('age').toString();
      bool dogIsWalking = element.get('isWalking');

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
                        Row(children: [
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
                            child: Icon(
                                Ionicons.ios_paw,
                                color: Color(
                                    dogIsWalking ? 0xff4f9567 : 0xffb60040
                                ),
                                size: 20
                            ),
                          )
                        ]),
                        SizedBox(height: 6),
                        Text(
                          dogBreed,
                          style: TextStyle(
                            color: Color(0xff48659e),
                            fontSize: 15,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.98,
                          ),
                        ),
                        Text(
                          (dogSex == "Male" ? "мальчик, " : "девочка, ") + dogAge + " лет",
                          style: TextStyle(
                            color: Color(0xff48659e),
                            fontSize: 15,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.98,
                          ),
                        )
                      ]),
                ],
              ),
            ),
          ],
        ),
      ));
    });

    return dogs;
  }

  getChatRoomId(String a, String b) {
    return ((a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0))
        ? "$b\_$a"
        : "$a\_$b");
  }

  void _onUserChatButtonPressed() async {

    List<String> users = [_myName, _personName];
    String chatRoomId = getChatRoomId(_myName, _personName);
    Map<String, dynamic> chatRoom = {
    "users": users,
    "chatroomId": chatRoomId,};
    DocumentSnapshot value = await FirebaseFirestore.instance
        .collection('chat_room').doc(chatRoomId).get();
    if(value.data() == null)
    {
      print('ЧАТА ЕЩЕ НЕТ');
      DatabaseMethods().createChatRoom(chatRoom, chatRoomId);
    }
    print('ЗАПУСКАЕМ ЧАТ');
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => Chat(
          chatRoomId: chatRoomId,
        )));

    setState(() {

      //тут надо сделать открытие чата с КОНКРЕТНЫМ пользователем
    });
  }

  void _onChatButtonPressed() {
    setState(() {
      //переход к окну с чатами
    });
  }

  void _onMapButtonPressed() {
    setState(() {
      Navigator.pushNamed(context, '/map/' + FirebaseAuth.instance.currentUser.uid); // изменил, т.к. мы задаем в итоге новый виджет карты,
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
                child:
                Container(
                  height: _personImageURL == null
                      ? MediaQuery.of(context).size.height * 0.45
                      : MediaQuery.of(context).size.height *
                      0.65, // как раз таки относительное взятие размеров окна
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _personImageURL == null
                          ? AssetImage(randomGif)
                          : CachedNetworkImageProvider(_personImageURL),
                      // придумать, что делать, пока фото грузится
                      // (может как-то использовать анимацию загрузки)
                      fit: _personImageURL == null ? BoxFit.none : BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2.2,
                child:
                Container(
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Container(
                            margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      _personName, //!!!!!!!!!!!!!!!! тут должно быть имя из БД
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
                                      margin: EdgeInsets.fromLTRB(0, 0, 0, 2.5),
                                      child: Icon(Ionicons.ios_paw,
                                          color: Color(_isWalking
                                              ? 0xff4f9567
                                              : 0xffb60040), size: 16),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                       _isWalking ? "на прогулке" : "сидит дома", //!!!!!!!!!!!!!!!! тут должен быть статус из БД
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
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 25, 0),
                          width: 68,
                          height: 43,
                          child:
                          ElevatedButton(
                              onPressed: _onUserChatButtonPressed,
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
                                  side: MaterialStateProperty.all(
                                      BorderSide(
                                          width: 155,
                                          style: BorderStyle.none,
                                          color: Color(0xffee870d))),
                                  enableFeedback: false,
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(22),
                                          side: BorderSide(
                                              color: Color(0xffee870d))))
                              ),
                              child:
                              Text(
                                "Чат",
                                style: TextStyle(
                                  color: Color(0xfffbfbfb),
                                  fontSize: 18,
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                        )
                      ]),
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
                        height: 130,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _dogs.toList(),
                        ),
                      ),
                      // ),*/
                      //дальше иконки
                      /* Positioned(
                      left: 40,
                      top: 72,
                      child: */
                      //!!!!!!!! color должен меняться в зависимости от БД
                      // ),
                      /* Positioned(
                      right: 22,
                      top: 35,
                      child: */

                      // ),
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
              /* Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                width: MediaQuery.of(context).size.width / 1.15,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onAddDogButtonPressed,
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xffee870d)),
                      foregroundColor: MaterialStateProperty.all(
                        Color(0xffee870d),
                      ),
                      overlayColor:
                          MaterialStateProperty.all(Color(0xffee870d)),
                      shadowColor: MaterialStateProperty.all(Color(0xffee870d)),
                      //elevation: MaterialStateProperty.all(20),
                      side: MaterialStateProperty.all(BorderSide(
                          style: BorderStyle.none, color: Color(0xffee870d))),
                      enableFeedback: false,
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(color: Color(0xffee870d))))
                      //shape: MaterialStateProperty.all(O)
                      ),
                  child: Text(
                    "Добавить собаку",
                    style: TextStyle(
                      color: Color(0xfffbfbfb),
                      fontSize: 20,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),*/
            ]));
    // })),
    //]));
  }
}