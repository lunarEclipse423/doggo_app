import 'package:flutter/material.dart';
import 'register.dart';
import 'input_phone_number.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

class WelcomeWindow extends StatefulWidget {
  @override
  _WelcomeWindowState createState() => _WelcomeWindowState();
}

class _WelcomeWindowState extends State<WelcomeWindow> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _autoAuth();
  }

  void _autoAuth() async
  {
    final Directory directory = await getApplicationDocumentsDirectory();
    String number = await getFileData('${directory.path}/auto_auth.txt');
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<DocumentSnapshot> documents = result.docs;
    documents.forEach((data) {
      if((data.get('phoneNumber') == number) && (data.get('auth') == true))
      {
        Navigator.pushNamedAndRemoveUntil(context, '/map/${data.id}', (route) => false);
      }
      else
      {
        return 0;
      }
    });
  }

  void _onLogInButtonPressed() {
    setState(() {
      Navigator.of(context).push(SwipeablePageRoute(
        builder: (BuildContext context) => InputPhoneNumberWindow(),
      ));
    });
  }

  void _onRegisterButtonPressed() {
    setState(() {
      Navigator.of(context).push(SwipeablePageRoute(
        builder: (BuildContext context) => RegisterWindow(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
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
                          Icon(Ionicons.ios_paw, color: Color(0xff789fff), size: 72),
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
                    SizedBox(height: 128.67),
                    Text(
                      "Добро пожаловать!",
                      style: TextStyle(
                        color: Color(0xff48659e),
                        fontSize: 18,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 18.67),
                    TextButton(
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
                              color: Color(0xffee870d),
                            ),
                          ),
                          Text(
                            "ВХОД",
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
                            "РЕГИСТРАЦИЯ",
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
                  ],
                ))));
  }
}
