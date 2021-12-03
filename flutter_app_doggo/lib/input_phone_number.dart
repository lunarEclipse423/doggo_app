import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps/input_code.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'const.dart';


class InputPhoneNumberWindow extends StatefulWidget {
  @override
  _InputPhoneNumberWindowState createState() => _InputPhoneNumberWindowState();
}

class _InputPhoneNumberWindowState extends State<InputPhoneNumberWindow> {
  String phoneNumber;
  bool find;
  void _onLogInButtonPressed() async {
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<DocumentSnapshot> documents = result.docs;
    setState(() {
      documents.forEach((data) async {
        find = true;
        if(data.get('phoneNumber') == phoneNumber) {
          register = false;
          Navigator.of(context).push(SwipeablePageRoute(
              builder: (context) =>
                  InputCodeWindow(phoneNumber, data.get('name'), null, false)));
        }
      }
      );
      if(find == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Аккаунт не найден!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: EdgeInsets.fromLTRB(0.0, 150, 0.0, 0.0),
            child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            enableFeedback: false,
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(22),
                                    side: BorderSide(
                                        color: Color(0x59c2d1f5))))
                        ),
                        child: Text(
                          "ВОЙТИ",
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
                  ],
                ))));
  }
}