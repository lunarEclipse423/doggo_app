import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/painting/box_decoration.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_icons/flutter_icons.dart';

class PersonProfile extends StatefulWidget {
  @override
  _PersonProfileState createState() => _PersonProfileState();
}

class _PersonProfileState extends State<PersonProfile> {
  String dogImageURL;
  String _personName = "Анастасия";
  String _description = "тут будет прекрасное описание собаки от хозяина";

  void initState() {
    super.initState();
/*
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/' + FirebaseAuth.instance.currentUser.uid + '/dogs/' +
        'Тян'
        + '/profile');

    storageReference.getDownloadURL().then((loc) => setState(() => dogImageURL = loc));*/
  }

  void _onBecomeFriendsButtonPressed() {
    setState(() {
      //добавление в друзья СДЕЛАТЬ
    });
  }

  void _onOpenSettingsButtonPressed()
  {
    setState(() {
      //тут надо сделать открытие настроек
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            height: dogImageURL == null ?
            MediaQuery.of(context).size.height * 0.45 :
            MediaQuery.of(context).size.height * 0.6, // как раз таки относительное взятие размеров окна
            decoration: BoxDecoration(
              image: DecorationImage(
                image: dogImageURL == null ?
                AssetImage('assets/loading.gif') : // придумать, что делать, пока фото грузится
                // (может как-то использовать анимацию загрузки)
                NetworkImage(dogImageURL),
                fit: dogImageURL == null ? BoxFit.none : BoxFit.fill,
              ),
            ),
          ),
          Container(
              alignment: Alignment.bottomCenter,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Positioned(
                                    left: 42,
                                    top: 40,
                                    child: Text(
                                      _personName, //!!!!!!!!!!!!!!!! тут должно быть имя из БД
                                      style: TextStyle(
                                        color: Color(0xff47659e),
                                        fontSize: 28,
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.96,
                                      ),
                                    )),
                                Positioned(
                                  left: 60,
                                  top: 75,
                                  child: Text(
                                    "на прогулке", //!!!!!!!!!!!!!!!! тут должен быть статус из БД
                                    style: TextStyle(
                                      color: Color(0xff3b7c51),
                                      fontSize: 12,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.84,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 42,
                                  top: 120,
                                  child: Text(
                                    "Питомцы",
                                    style: TextStyle(
                                      color: Color(0xff47659e),
                                      fontSize: 18,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.26,
                                    ),
                                  ),
                                ),
                                //дальше иконки

                                Positioned(
                                  left: 40,
                                  top: 72,
                                  child: Icon(Ionicons.ios_paw,
                                      color: Color(0xff4f9567),
                                      size:
                                      18), //!!!!!!!! color должен меняться в зависимости от БД
                                ),
                                Positioned(
                                    left: 42,
                                    top: 194,
                                    child: SizedBox(
                                      width: 307,
                                      height: 100,
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
                                    )),
                                Positioned(
                                  right: 22,
                                  top: 35,
                                  child: IconButton(icon: const Icon(FluentIcons.settings_24_regular, color: Color(0xff48659e)),
                                      iconSize: 40,
                                      onPressed: _onOpenSettingsButtonPressed
                                  ),
                                ),
                              ],
                            ),
                            height: constraints.maxHeight * 0.45, // высота блока информации в профиле
                            width: constraints.maxWidth,
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
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                            width: MediaQuery.of(context).size.width / 1.15,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _onBecomeFriendsButtonPressed,
                              style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all(Color(0xff789fff)),
                                  foregroundColor: MaterialStateProperty.all(
                                    Color(0xff789fff),
                                  ),
                                  overlayColor:
                                  MaterialStateProperty.all(Color(0xff789fff)),
                                  shadowColor:
                                  MaterialStateProperty.all(Color(0xff789fff)),
                                  //elevation: MaterialStateProperty.all(20),
                                  side: MaterialStateProperty.all(BorderSide(
                                      style: BorderStyle.none,
                                      color: Color(0xff789fff))),
                                  enableFeedback: false,
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(22),
                                          side: BorderSide(color: Color(0xff789fff))))
                                //shape: MaterialStateProperty.all(O)
                              ),
                              child: Text(
                                "Перейти к хозяину",
                                style: TextStyle(
                                  color: Color(0xfffbfbfb),
                                  fontSize: 18,
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ]);
                  })),
        ]));
  }
}
