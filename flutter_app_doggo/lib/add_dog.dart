import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class AddDogWindow extends StatefulWidget {
  @override
  _AddDogWindowState createState() => _AddDogWindowState();
}

class _AddDogWindowState extends State<AddDogWindow> {
  void _onAddPhotoButtonPressed() {
    setState(() {
      //тут надо сделать добавление фото в БД
    });
  }
  void _onAddDogButtonPressed() {
    setState(() {
      //!!!!!!!!!!!!!!! тут надо сделать добавление собаки в БД (с привязкой к юзеру)
      Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
    });
  }

  void _onNotAddDogButtonPressed() {
    setState(() {
      Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(0.0, 120, 0.0, 0.0),
            child: Column(
              children: [
                Text(
                  "Время добавить вашу собачку!",
                  style: TextStyle(
                    color: Color(0xff48659e),
                    fontSize: 17,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.98,
                  ),
                ),
                SizedBox(height: 38.67),
                SizedBox(width: 150,
                  height: 150,
                  child:
                ElevatedButton(onPressed: _onAddPhotoButtonPressed,
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xfffbfbfb)),
                        foregroundColor: MaterialStateProperty.all(Color(0xfffbfbfb),),
                        overlayColor: MaterialStateProperty.all(Color(0xfffbfbfb)),
                        shadowColor: MaterialStateProperty.all(Color(0xfffbfbfb)),
                        //elevation: MaterialStateProperty.all(20),
                        side: MaterialStateProperty.all(BorderSide(width: 155, style: BorderStyle.none, color: Color(0xfffbfbfb))),
                        enableFeedback: false,
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: Color(0x59c2d1f5))
                            )
                        )
                        //shape: MaterialStateProperty.all(O)
                    ),
                    child:
               /* Container(
                  width: 150,
                  height: 150,
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
                  child:*/

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(MaterialIcons.add_a_photo,
                          color: Color(0x7f789fff), size: 80),
                      SizedBox(height: 10.67),
                      Text(
                        "добавить фото",
                        style: TextStyle(
                          color: Color(0xb248659e),
                          fontSize: 12,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.84,
                        ),
                      ),
                    ],
                  ),),
                ),
               // ),
                SizedBox(height: 38.67),
                Container(
                  width: 300,
                  child: TextFormField(
                      //initialValue: "имя собаки",
                    style: TextStyle(
                      color: Color(0xff2c4880),
                      fontSize: 15,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.84,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Color(0xff2c4880),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                          color: Color(0xb248659e),
                          width: 1.0,
                        ),
                      ),
                      hoverColor: Color(0xb248659e),
                      focusColor: Color(0xb248659e),
                      labelText: "имя собаки",
                        labelStyle: TextStyle(
                          color: Color(0xb248659e),
                          fontSize: 12,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.84,
                        ),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 11.67),
                Container(
                  width: 300,
                  child: TextFormField(
                    style: TextStyle(
                      color: Color(0xff2c4880),
                      fontSize: 15,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.84,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Color(0xff2c4880),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                          color: Color(0xb248659e),
                          width: 1.0,
                        ),
                      ),
                      hoverColor: Color(0xb248659e),
                      focusColor: Color(0xb248659e),
                      labelText: "пол",
                      labelStyle: TextStyle(
                        color: Color(0xb248659e),
                        fontSize: 12,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.84,
                      ),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 11.67),
                Container(
                  width: 300,
                  child: TextFormField(
                    style: TextStyle(
                      color: Color(0xff2c4880),
                      fontSize: 15,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.84,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Color(0xff2c4880),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                          color: Color(0xb248659e),
                          width: 1.0,
                        ),
                      ),
                      hoverColor: Color(0xb248659e),
                      focusColor: Color(0xb248659e),
                      labelText: "порода",
                      labelStyle: TextStyle(
                        color: Color(0xb248659e),
                        fontSize: 12,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.84,
                      ),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 35.67),
            SizedBox(width: 300,
              height: 55,
              child:
                ElevatedButton(
                  onPressed: _onAddDogButtonPressed,
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xff789fff)),
                      foregroundColor: MaterialStateProperty.all(Color(0xff789fff),),
                      overlayColor: MaterialStateProperty.all(Color(0xff789fff)),
                      shadowColor: MaterialStateProperty.all(Color(0xff789fff)),
                      //elevation: MaterialStateProperty.all(20),
                     // side: MaterialStateProperty.all(BorderSide(width: 155, style: BorderStyle.none, color: Color(0xff789fff))),
                      enableFeedback: false,
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(color: Color(0x59c2d1f5))
                          )
                      )
                    //shape: MaterialStateProperty.all(O)
                  ),
                  child: /*Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 300,
                            minHeight: 60,
                            //maxWidth: 2 * MediaQuery.of(context).size.height / 3,
                            //maxHeight: 2 * MediaQuery.of(context).size.height / 3),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Color(0xffffffff),
                              blurRadius: 4,
                              offset: Offset(0, -4),
                            ),
                          ],
                          color: Color(0xff789fff),
                        ),
                      ),*/
                      Text(
                        "Добавить любимца",
                        style: TextStyle(
                          color: Color(0xfffbfbfb),
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      )
                  ),
            ),
            SizedBox(height: 12),
                SizedBox(width: 300,
                  height: 55,
                  child:
                  ElevatedButton(
                      onPressed: _onNotAddDogButtonPressed,
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xffee870d)),
                          foregroundColor: MaterialStateProperty.all(Color(0xffee870d),),
                          overlayColor: MaterialStateProperty.all(Color(0xffee870d)),
                          shadowColor: MaterialStateProperty.all(Color(0xffee870d)),
                          //elevation: MaterialStateProperty.all(20),
                          side: MaterialStateProperty.all(BorderSide(width: 155, style: BorderStyle.none, color: Color(0xffee870d))),
                          enableFeedback: false,
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  side: BorderSide(color: Color(0xffee870d))
                              )
                          )
                        //shape: MaterialStateProperty.all(O)
                      ),
                      child: /*Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 300,
                            minHeight: 60,
                            //maxWidth: 2 * MediaQuery.of(context).size.height / 3,
                            //maxHeight: 2 * MediaQuery.of(context).size.height / 3),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Color(0xffffffff),
                              blurRadius: 4,
                              offset: Offset(0, -4),
                            ),
                          ],
                          color: Color(0xff789fff),
                        ),
                      ),*/
                      Text(
                        "Не сейчас...",
                        style: TextStyle(
                          color: Color(0xfffbfbfb),
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      )
                  ),
                ),
              ],
            ))));
  }
}
