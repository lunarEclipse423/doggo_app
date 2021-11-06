import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class AddDogWindow extends StatefulWidget {
  @override
  _AddDogWindowState createState() => _AddDogWindowState();
}

enum Gender { male, female }

class _AddDogWindowState extends State<AddDogWindow> {
  bool _pressedButtonFemale = true;
  bool _pressedButtonMale = false;
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = "";
  String selectedValue = "выбери породу";
  int number;

  final List<DropdownMenuItem> items = [];

  @override
  void initState() {
    items.add(DropdownMenuItem(
      child: Text("Мальтезе"),
      value: "Мальтезе",
    ));
    items.add(DropdownMenuItem(
      child: Text("Чихуахуа"),
      value: "Чихуахуа",
    ));
    items.add(DropdownMenuItem(
      child: Text("Лабрадорчик"),
      value: "Лабрадорчик",
    ));
    super.initState();
  }

  void _onAddPhotoButtonPressed() {
    setState(() {
      //тут надо сделать добавление фото в БД
    });
  }

  void _onAddDogButtonPressed() {
    setState(() {
      //!!!!!!!!!!!!!!! тут надо сделать добавление собаки в БД (с привязкой к юзеру)
      Navigator.pushNamedAndRemoveUntil(context, '/map/${FirebaseAuth.instance.currentUser.uid}', (route) => false);
    });
  }

  void _onNotAddDogButtonPressed() {
    setState(() {
      Navigator.pushNamedAndRemoveUntil(context, '/map/${FirebaseAuth.instance.currentUser.uid}', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(0.0, 120, 0.0, 0.0),
                child: Builder(
                    builder: (context) => Form(
                        key: _formKey,
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
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: ElevatedButton(
                                onPressed: _onAddPhotoButtonPressed,
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xfffbfbfb)),
                                    foregroundColor: MaterialStateProperty.all(
                                      Color(0xfffbfbfb),
                                    ),
                                    overlayColor: MaterialStateProperty.all(
                                        Color(0xfffbfbfb)),
                                    shadowColor: MaterialStateProperty.all(
                                        Color(0xfffbfbfb)),
                                    //elevation: MaterialStateProperty.all(20),
                                    side: MaterialStateProperty.all(BorderSide(
                                        width: 155,
                                        style: BorderStyle.none,
                                        color: Color(0xfffbfbfb))),
                                    enableFeedback: false,
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            side: BorderSide(
                                                color: Color(0x59c2d1f5))))
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
                                ),
                              ),
                            ),
                            // ),
                            SizedBox(height: 38.67),
                            Container(
                              width: 300,
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "please enter your dog's name :)";
                                  }
                                },
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
                                  labelText: "  имя собаки",
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
                            SizedBox(height: 30.67),
                            Text(
                              "выберите пол собаки",
                              style: TextStyle(
                                color: Color(0xb248659e),
                                fontSize: 12,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.84,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(children: [
                                    Container(
                                      height: 47,
                                    child: ElevatedButton(
                                        child: Icon(Boxicons.bx_female_sign,
                                            color: _pressedButtonFemale ? Colors.white : Color (0xb248659e)),
                                        onPressed: () => setState(() =>
                                        {
                                          if (!_pressedButtonMale)
                                        {
                                          if (!_pressedButtonFemale)
                                            {
                                              _pressedButtonFemale = ! _pressedButtonFemale,
                                            }
                                        //!!!!!!!!!! добавить в БД женский пол
                                        }
                                            else
                                            {
                                            _pressedButtonFemale = !_pressedButtonFemale,
                                            _pressedButtonMale = ! _pressedButtonMale,
                                            },

                                        }),
                                        /*   //elevation: MaterialStateProperty.all(20),
                                          // side: MaterialStateProperty.all(BorderSide(width: 155, style: BorderStyle.none, color: Color(0xff789fff))),


                                        //shape: MaterialStateProperty.all(O)
                                      ),*/
                                        style: _pressedButtonFemale
                                            ? ButtonStyle(
                                                shape: MaterialStateProperty.all<
                                                        CircleBorder>(
                                                    CircleBorder(
                                                        side: BorderSide(
                                                            color: Color(
                                                                0x7f789fff)))),
                                               //enableFeedback: false,
                                               /* minimumSize:
                                                    MaterialStateProperty.all(
                                                        Size.fromWidth(49)),*/
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Color(0x7f789fff)),
                                                /*foregroundColor:
                                                    MaterialStateProperty.all(
                                                  Color(0x7f789fff),
                                                ),
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                        Color(0x7f789fff)),*/
                                                /*shadowColor:
                                                    MaterialStateProperty.all(
                                                        Color(0x7f789fff)),*/
                                                /*    Container(
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
                                       color: Color(0x7f789fff),
                                     ),*/
                                              )
                                            : ButtonStyle(
                                                shape: MaterialStateProperty.all<
                                                        CircleBorder>(
                                                    CircleBorder(
                                                        side: BorderSide(
                                                            color: Color(
                                                                0xfffbfbfb)))),
                                               enableFeedback: false,
                                               /* minimumSize:
                                                    MaterialStateProperty.all(
                                                        Size.fromWidth(49)),*/
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Color(0xfffbfbfb)),
                                               /* foregroundColor:
                                                    MaterialStateProperty.all(
                                                  Color(0xfffbfbfb),
                                                ),
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                        Color(0xfffbfbfb)),
                                                shadowColor:
                                                    MaterialStateProperty.all(
                                                        Color(0xfffbfbfb)),*/
                                              ))),
                                    /*  Column(children: [
                                     Container(
                                       width: 49,
                                       height: 49,
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
                                       child: Icon(
                                         Boxicons.bx_female_sign,
                                         color: Color(0xb248659e),
                                       ),
                                     )]),),*/
                                    SizedBox(height: 10),
                                    Text(
                                      "девочка",
                                      style: TextStyle(
                                        color: Color(0xb248659e),
                                        fontSize: 11,
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.77,
                                      ),
                                    ),
                                  ]),
                                  SizedBox(width: 20),
    Column(children: [
                                  Container(
                                      height: 47,
                                      child: ElevatedButton(
                                          child: Icon(Boxicons.bx_male_sign,
                                              color: _pressedButtonMale ? Colors.white : Color (0xb248659e)),
                                          onPressed: () => setState(() =>
                                          {
                                            if (!_pressedButtonFemale)
                                              {
                                                if (!_pressedButtonMale)
                                                  {
                                                    _pressedButtonMale =
                                                    !_pressedButtonMale
                                                  }
                                                //!!!!!!!!!! добавить в БД мужской пол
                                              }
                                            else
                                              {
                                                _pressedButtonMale = ! _pressedButtonMale,
                                                _pressedButtonFemale = !_pressedButtonFemale
                                              }
                                          }),
                                          style: _pressedButtonMale
                                              ? ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                CircleBorder>(
                                                CircleBorder(
                                                    side: BorderSide(
                                                        color: Color(
                                                            0x7f789fff)))),
                                            backgroundColor:
                                            MaterialStateProperty.all(
                                                Color(0x7f789fff)),
                                          )
                                              : ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                CircleBorder>(
                                                CircleBorder(
                                                    side: BorderSide(
                                                        color: Color(
                                                            0xfffbfbfb)))),
                                            enableFeedback: false,
                                            backgroundColor:
                                            MaterialStateProperty.all(
                                                Color(0xfffbfbfb)),
                                          ))),
                                  SizedBox(height: 10),
                                  Text(
                                    "мальчик",
                                    style: TextStyle(
                                      color: Color(0xb248659e),
                                      fontSize: 11,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.77,
                                    ),
                                  ),
                    ]),
                                  ]),
                            SizedBox(height: 11.67),
                            Container(
                              width: 300,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "please enter your dog's age :)";
                                  }
                                  if (int.parse(value) >= 40 ||
                                      int.parse(value) < 0) {
                                    return "please enter your dog's REAL age :)";
                                  }
                                },
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
                                  labelText: "  возраст собаки",
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

                            SizedBox(height: 30.67),
                            Container(
                              width: 300,
                              //height: 60,
                              /*decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff889abe)),
                              borderRadius: BorderRadius.circular(15.0),
                              ),*/
                              //height: 70,
                              child: SearchableDropdown.single(
                                menuBackgroundColor: Color(0xfffbfbfb),
                                underline: Column(children: <Widget>[
                                  Divider(
                                      thickness: 1,
                                      height: 3,
                                      color: Color(0xb248659e)),
                                ]),
                                hint: Container(
                                  height: 34,
                                  child: Text(
                                    "выбери породу",
                                    style: TextStyle(
                                      color: Color(0xb248659e),
                                      fontSize: 12,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.84,
                                    ),
                                  ),
                                ),
                                // searchHint: "Выбери породу",
                                searchHint: null,
                                dialogBox: false,
                                isExpanded: true,
                                menuConstraints:
                                    BoxConstraints.tight(Size.fromHeight(400)),
                                closeButton: "Закрыть",
                                displayClearIcon: false,
                                icon: const Icon(EvaIcons.arrowIosDownward,
                                    color: Color(0xb248659e)),
                                style: TextStyle(
                                  color: Color(0xb248659e),
                                  fontSize: 12,
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.84,
                                ),
                                items: items,
                                value: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    //selectedValue = value;
                                  });
                                },
                              ),
                            ),

                            //сука МИЛЛИАРД И ОДНА ПОПЫТКА СДЕЛАТЬ МЕНЮШКУ
                            // SingleChildScrollView(child:
                            /*SizedBox(
                              width: 300,
                              height: 50,
                              child: DropdownSearch<String>(
                                searchBoxDecoration: InputDecoration(focusedBorder: OutlineInputBorder(
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
                                  labelText: "начни здесь писать название породы!",
                                  labelStyle: TextStyle(
                                    color: Color(0xb248659e),
                                    fontSize: 12,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.84,
                                  ),
                                  border: UnderlineInputBorder(),
                                ),
                                showSearchBox: true,
                                  isFilteredOnline: true,
                                validator: (v) => v == null
                                    ? "please choose your dog's breed :)"
                                    : null,
                                hint: "выбери породу",
                                mode: Mode.MENU,
                                showSelectedItem: true,
                                items: [
                                  "Мальтезе",
                                  "Лабрадор",
                                  "Мопс",
                                  'Чихуахуа'
                                ],
                                showClearButton: true,
                                //onChanged: print,
                                popupItemDisabled: (String s) =>
                                    s.startsWith('I'),
                                //selectedItem: "Tunisia",
                              ),
                              ),*/
                            // ),

                            /* DropdownButton<String>(
                              value: dropdownValue,
                              //icon: const Icon(EvaIcons.arrowIosDownward),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(
                                color: Color(0xb248659e),
                                fontSize: 12,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.84,
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  dropdownValue = newValue;
                                });
                              },
                              items: <String>[
                                'Мальтезе',
                                'Лабрадор',
                                'Мопс',
                                'Чихуахуа'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),*/
                            /*Container(
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
                            ),*/
                            SizedBox(height: 35.67),
                            SizedBox(
                              width: 300,
                              height: 55,
                              child: ElevatedButton(
                                  onPressed: () {
                                    final form = _formKey.currentState;
                                    if (form.validate()) {
                                      _onAddDogButtonPressed();
                                    }
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xff789fff)),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                        Color(0xff789fff),
                                      ),
                                      overlayColor: MaterialStateProperty.all(
                                          Color(0xff789fff)),
                                      shadowColor: MaterialStateProperty.all(
                                          Color(0xff789fff)),
                                      //elevation: MaterialStateProperty.all(20),
                                      // side: MaterialStateProperty.all(BorderSide(width: 155, style: BorderStyle.none, color: Color(0xff789fff))),
                                      enableFeedback: false,
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              side: BorderSide(
                                                  color: Color(0x59c2d1f5))))
                                      //shape: MaterialStateProperty.all(O)
                                      ),
                                  child:
                                      /*Stack(
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
                                  )),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: 300,
                              height: 55,
                              child: ElevatedButton(
                                  onPressed: _onNotAddDogButtonPressed,
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
                                      //shape: MaterialStateProperty.all(O)
                                      ),
                                  child:
                                      /*Stack(
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
                                  )),
                            ),
                          ],
                        ))))));
  }
}

class ChooseBreedWindow extends StatefulWidget {
  @override
  _ChooseBreedWindowState createState() => _ChooseBreedWindowState();
}

class _ChooseBreedWindowState extends State<ChooseBreedWindow> {
  @override
  Widget build(BuildContext context) {}
}
