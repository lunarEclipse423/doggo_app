import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'input_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';



class RegisterWindow extends StatefulWidget {
  @override
  _RegisterWindowState createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  String phoneNumber;
  String name;
  final _formKey = GlobalKey<FormState>();

  bool isPicked = false;
  bool isCropped = false;
  final cropKey = GlobalKey<CropState>();

  File sampleImage;
  File personImage;

  List<Widget> buttonList = [
    Icon(MaterialIcons.add_a_photo,
      color: Color(0x7f789fff),
      size: 80,
    ),
    SizedBox(
        height: 10.67
    ),
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
  ];

  void _onAddPhotoButtonPressed() async {
    await _pickImage();

    setState(() {
      isPicked = true;
      isCropped = false;
    });
  }

  void _onCropButtonPressed() async {
    await _cropImage();

    setState(() {
      isPicked = false;
      isCropped = true;

      buttonList = List<Widget>.filled(1,
          Container(
            alignment: Alignment.center,
            height: 125,
            width: 125,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(personImage),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          )
      );
    });
  }

  void _onRegisterButtonPressed() async {
    bool isAuth = false;
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<DocumentSnapshot> documents = result.docs;
    setState(() {
      documents.forEach((data) async {
        if(data.get('phoneNumber') == phoneNumber)
        {
          isAuth = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:Text('Вы уже зарегистрированы!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      );
      if(isAuth == false) {
        print('Register -> Code');
        Navigator.of(context).push(SwipeablePageRoute(
            builder: (context) => InputCodeWindow(phoneNumber, name, personImage, true)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      return ((isPicked == true && isCropped == false)
          ? _buildCropWidget()
          : _buildRegisterWidget());
    }
    on Exception catch(e) {
      print('error caught: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    final file = File(pickedFile.path);

    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: context.size.longestSide.ceil(),
    );

    personImage = file;
    sampleImage = sample;

    debugPrint('$personImage');
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;

    if (area == null) {
      return;
    }

    final sample = await ImageCrop.sampleImage(
      file: personImage,
      preferredSize: (2000 / scale).round(),
    );

    final croppedImage = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    personImage = croppedImage;

    debugPrint('$croppedImage');
  }

  Widget _buildRegisterWidget () {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            margin: EdgeInsets.fromLTRB(0.0, 150, 0.0, 0.0),
            child: Builder(
                builder: (context) => Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // ЛОГОТИП "DOGGO"
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
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Invalid Name';
                                  }},
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
                                  style:
                                  TextStyle(
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
                            // КНОПКА "ПРОДОЛЖИТЬ"
                            TextButton(
                              onPressed: () {
                                final form = _formKey.currentState;
                                if (form.validate()) {
                                  _onRegisterButtonPressed();
                                }},
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
                        ))))
        )
    );
  }


  Widget _buildCropWidget() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(sampleImage, key: cropKey),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text(
                  'Crop Image',
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.white),
                ),
                onPressed: () => _onCropButtonPressed(),
              ),
            ],
          ),
        )
      ],
    );
  }
}