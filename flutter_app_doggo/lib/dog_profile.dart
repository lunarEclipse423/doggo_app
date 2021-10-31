import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/painting/box_decoration.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_icons/flutter_icons.dart';


class DogProfile extends StatefulWidget {
  @override
  _DogProfileState createState() => _DogProfileState();
}

class _DogProfileState extends State<DogProfile> {
  void _onBecomeFriendsButtonPressed() {
    setState(() {
      //тут надо сделать добавление в друзья
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[

        Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                child: Stack(
                  children: [
                    Positioned(
                        left: 42,
                        top: 45,
                        child: Text(
                          "Жусц", //!!!!!!!!!!!!!!!! тут должно быть имя из БД
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.96,
                          ),
                        )),
                    Positioned(
                      left: 60,
                      top: 80,
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
                      left: 90,
                      top: 124,
                      child: Text(
                        "Мальтезе", //!!!!!!!!!!!!!!!! тут должна быть порода из БД
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.26,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 252,
                      top: 124,
                      child: Text(
                        "мальчик", //!!!!!!!!!!!!!!!! тут должен быть пол из БД
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.26,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 42,
                      top: 190,
                      child: Text(
                        "Друзья",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.75,
                        ),
                      ),
                    ),

                    //дальше иконки
                    Positioned(
                      left: 36,
                      top: 112,
                      child: Container(
                        width: 44,
                        height: 44,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                color: Color(0xfff1eaea),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Center(
                                        child:
                                            Icon(Ionicons.ios_paw, size: 35)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      left: 198,
                      top: 112,
                      child: Container(
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
                            color: Color(0xfff1eaea),
                          ),
                            child: Container(
                                child: Stack(children: [
                              Positioned(
                                  top: 10,
                                  right: 17,
                                  child: Container(
                                      child: Icon(Boxicons.bx_female_sign,
                                          size: 23))),
                              Positioned(
                                  top: 10,
                                  left: 17,
                                  child: Transform.rotate(
                                      angle: -0.79,
                                      child: Icon(Boxicons.bx_male_sign,
                                          size: 23)))
                            ], overflow: Overflow.visible)),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 40,
                      top: 77,
                        child: Icon(Ionicons.ios_paw, color: Color(0xff4f9567), size: 18), //!!!!!!!! color должен меняться в зависимости от БД
                      ),
                  ],
                ),
                height: constraints.maxHeight / 2,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  color: Color(0xfff1e9e9),
                ),
              );
            })),
        Expanded(
            child: Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            child: Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
              width: double.infinity,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3f000000),
                    blurRadius: 10,
                    offset: Offset(4, 4),
                  ),
                  BoxShadow(
                    color: Color(0xffffffff),
                    blurRadius: 7,
                    offset: Offset(-4, -4),
                  ),
                ],
                color: Color(0xff847171),
              ),
              child: Center(
                child: Text(
                  "Подружиться",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.54,
                  ),
                ),
              ),
            ),
            onPressed: _onBecomeFriendsButtonPressed,
          ),
        )),
      ]),
    );
  }
}
