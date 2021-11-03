import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'input_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';


class RegisterWindow extends StatefulWidget {
  final bool register;
  RegisterWindow(this.register);
  @override
  _RegisterWindowState createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  String phoneNumber;
  String name;

  void _onRegisterButtonPressed() async {
    bool isAuth = false;
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<DocumentSnapshot> documents = result.docs;
    setState(() {
      documents.forEach((data) async {
        if(data.get('phoneNumber') == phoneNumber)
        {
          if(widget.register == true) {
            isAuth = true;
            FocusScope.of(context).unfocus();
            GlobalKey<ScaffoldState>().currentState
                .showSnackBar(SnackBar(content: Text('Вы уже зарегистрированны!')));
            print("Уже зареган!");
          }
        }
      }
      );
      if(isAuth == false) {
        Navigator.of(context).push(SwipeablePageRoute(
            builder: (context) => InputCodeWindow(phoneNumber, name)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            margin: EdgeInsets.fromLTRB(0.0, 150, 0.0, 0.0),
            child: Column(
              children: [
                Container(
                  width: 112,
                  height: 112,
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
                      Icon(Ionicons.ios_paw,
                          color: Color(0xff789fff), size: 72),
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
                SizedBox(height: 88.67),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(55.0, 0.0, 0.0, 0.0),
                    child: Text(
                      "введите ваше имя:",
                      style: TextStyle(
                        color: Color(0xb248659e),
                        fontSize: 14,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.84,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  child: TextFormField(
                      style: TextStyle(
                        color: Color(0xff2c4880),
                        fontSize: 14,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.84,
                      ),
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (input)
                    {
                      name = input;
                    },
                  ),
                ),
                SizedBox(height: 48.67),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(55.0, 0.0, 0.0, 0.0),
                    child: Text(
                      "введите номер телефона:",
                      style: TextStyle(
                        color: Color(0xb248659e),
                        fontSize: 14,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.84,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  child: IntlPhoneField(
                    showDropdownIcon: false,
                    style: TextStyle(
                        color: Color(0xff48659e),
                        fontSize: 15,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.84),
                    countryCodeTextColor: Color(0xb248659e),
                    //dropDownArrowColor: Color(0xff789fff),
                    searchText: "Введи название своей страны:",
                    initialCountryCode: 'RU', //default contry code
                    onChanged: (phone) {
                      //when phone number country code is changed
                      phoneNumber = phone.completeNumber;
                    },
                  ),
                ),
                SizedBox(height: 38.67),
                TextButton(
                  onPressed: _onRegisterButtonPressed,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 238,
                            minHeight: 51,
                            //maxWidth: 2 * MediaQuery.of(context).size.height / 3,
                            //maxHeight: 2 * MediaQuery.of(context).size.height / 3),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
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
                      ),
                      Text(
                        "ПРОДОЛЖИТЬ",
                        style: TextStyle(
                          color: Color(0xfffbfbfb),
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10.67),
              ],
            )));
  }
}
