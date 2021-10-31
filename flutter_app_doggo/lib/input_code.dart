import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pin_put/pin_put.dart';

class InputCodeWindow extends StatefulWidget {
  @override
  _InputCodeWindowState createState() => _InputCodeWindowState();
}

class _InputCodeWindowState extends State<InputCodeWindow> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: Color(0x7248659e),
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: EdgeInsets.fromLTRB(0.0, 150, 0.0, 0.0),
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
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      "Привет, " + "<имя>!", //!!!!!!!!!!!тут должно отображаться имя пользователя из БД
                      style: TextStyle(
                        color: Color(0xff48659e),
                        fontSize: 14,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.98,
                      ),
                  ),
                )),
                SizedBox(height: 14.67),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      child:Text(
                        "введите код из СМС",
                        style: TextStyle(
                          color: Color(0xb248659e),
                          fontSize: 12,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.84,
                        ),
                      ),
                    )),
                SizedBox(height: 38.67),
                PinPut(
                  fieldsCount: 6,
                    fieldsAlignment: MainAxisAlignment.spaceEvenly,
                  textStyle: const TextStyle(
                    color: Color(0xfffbfbfb),
                    fontSize: 20,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w700,
                  ),
                  eachFieldWidth: 46.0,
                  eachFieldHeight: 52.0,
                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  submittedFieldDecoration: pinPutDecoration,
                  selectedFieldDecoration: pinPutDecoration,
                  followingFieldDecoration: pinPutDecoration,
                  pinAnimationType: PinAnimationType.fade,
                  onSubmit: (pin) async {
                    try {
                      await FirebaseAuth.instance
                          .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: pin))
                          .then((value) async {
                        if (value.user != null) {
                          Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
                        }
                      });
                    } catch (e) {
                      FocusScope.of(context).unfocus();
                      _scaffoldkey.currentState
                          .showSnackBar(SnackBar(content: Text('invalid OTP')));
                    }
                  },
                ),
                SizedBox(height: 58.67),
               /* TextButton(
                  onPressed: _onLogInButtonPressed,
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
                ),*/
                SizedBox(height: 10.67),
              ],
            )));
  }
}
