import 'dart:ui';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_crop/image_crop.dart';

class DogSettings extends StatefulWidget {
  final String _currentUid;
  final String _dogID;
  DogSettings(String uid, String uidDog):
        _currentUid = uid,
        _dogID = uidDog;
  @override
  _DogSettingsState createState() => _DogSettingsState();
}

enum Gender { male, female }

class _DogSettingsState extends State<DogSettings> {
  bool _pressedButtonFemale = false;
  bool _pressedButtonMale = false;
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = "";
  String selectedValue = "выбери породу";

  String _dogImageURL;

  bool isPicked = false;
  bool isCropped = false;
  final cropKey = GlobalKey<CropState>();

  File sampleImage;
  File dogImage;

  String _name = "";
  String _sex = "";
  int _age;
  String _breed = "";
  String _description = "";

  final List<DropdownMenuItem> items = [];
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

  @override
  void initState() {
    super.initState();

    _getDogData();
    _fillList();
  }

  void _getDogData() async {
    final DocumentSnapshot dog = await FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid)
        .collection('dogs')
        .doc(widget._dogID).get();

    _name = dog.get('name');
    _sex = dog.get('sex') == 'Female' ? 'Девочка' : 'Мальчик';

    if(_sex == 'Female') {
      _pressedButtonFemale = true;
      _pressedButtonMale = false;
    }
    else {
      _pressedButtonFemale = false;
      _pressedButtonMale = true;
    }

    _breed = dog.get('breed');
    selectedValue = _breed;

    _age = dog.get('age');
    _description = dog.get('description');

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/' + widget._currentUid + '/dogs/' + widget._dogID + '/profile');

    await storageReference.getDownloadURL().then((fileURL) {
      _dogImageURL =  fileURL;
    });

    setState(() {});
  }

  void _fillList() async {
    List<String> breeds = (await rootBundle.loadString('assets/breeds.txt')).split('\n');

    breeds.forEach((breed) {
      items.add(DropdownMenuItem(
        child: Text(breed),
        value: breed,
      ));
    });
  }

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
                image: FileImage(dogImage),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          )
      );
    });
  }

  void _onSaveSettingsButton() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/' + widget._currentUid + '/dogs/' + widget._dogID + '/profile');

    if (dogImage != null) {
      UploadTask uploadTask = storageReference.putFile(dogImage);
      print('File Uploaded');
    }

    setState(() {
      FirebaseFirestore.instance.collection('users')
          .doc(widget._currentUid)
          .collection('dogs')
          .doc(widget._dogID)
          .update(
            {'name': _name, 'sex': _sex, 'age': _age, 'breed': _breed, 'description' : _description}
      );

      Navigator.pushNamedAndRemoveUntil(context, '/map/${widget._currentUid}', (route) => false);
    });
  }

  void _onNotAddDogButtonPressed() {
    setState(() {
      Navigator.pushNamedAndRemoveUntil(context, '/map/${widget._currentUid}', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      return ((isPicked == true && isCropped == false)
          ? _buildCropWidget()
          : _buildAddingDog());
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

    dogImage = file;
    sampleImage = sample;

    debugPrint('$dogImage');
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;

    if (area == null) {
      return;
    }

    final sample = await ImageCrop.sampleImage(
      file: dogImage,
      preferredSize: (2000 / scale).round(),
    );

    final croppedImage = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    dogImage = croppedImage;

    debugPrint('$croppedImage');
  }

  Widget _buildAddingDog () {
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
                              "НАСТРОЙКИ",
                              style: TextStyle(
                                color: Color(0xff48659e),
                                fontSize: 24,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.54,
                              ),
                            ),
                            Text(
                              "профиля собаки",
                              style: TextStyle(
                                color: Color(0xb248659e),
                                fontSize: 20,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.26,
                              ),
                            ),
                            SizedBox(height: 38.67),
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: ElevatedButton(
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
                                        borderRadius: BorderRadius.circular(30),
                                        side: BorderSide(
                                            color: Color(0x59c2d1f5)),
                                      ),
                                    ),
                                  ),
                                  onPressed: _onAddPhotoButtonPressed,
                                  child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          height: 125,
                                          width: 125,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: (_dogImageURL == null && dogImage == null
                                                  ? AssetImage('assets/sleep_dog.gif')
                                                  : (dogImage == null
                                                    ? NetworkImage(_dogImageURL)
                                                    : FileImage(dogImage))
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(30),
                                          ),
                                        ),
                                      ])),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "изменить фото",
                              style: TextStyle(
                                color: Color(0xb248659e),
                                fontSize: 12,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.84,
                              ),
                            ),
                            SizedBox(height: 38.67),
                            Container(
                              width: 300,
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: _name
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "please enter your dog's name :)";
                                  }
                                },
                                style: TextStyle(
                                  color: Color(0xff2c4880),
                                  fontSize: 12,
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
                                    fontSize: 14,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.84,
                                  ),
                                ),
                                onChanged: (value) {
                                  _name = value;
                                },
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              "измените пол собаки",
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
                                  Column(
                                      children: [
                                        Container(
                                            height: 47,
                                            child: ElevatedButton(
                                                child: Icon(Boxicons.bx_female_sign,
                                                    color: _pressedButtonFemale ? Colors.white : Color (0xb248659e)
                                                ),
                                                onPressed: () => setState(() =>
                                                {
                                                  if (!_pressedButtonMale)
                                                    {
                                                      if (!_pressedButtonFemale)
                                                        {
                                                          _pressedButtonFemale = !_pressedButtonFemale,
                                                        },
                                                    }
                                                  else
                                                    {
                                                      _pressedButtonFemale = !_pressedButtonFemale,
                                                      _pressedButtonMale = ! _pressedButtonMale,
                                                    },
                                                  _sex = "Female",
                                                }),
                                                style: _pressedButtonFemale
                                                    ? ButtonStyle(
                                                  shape: MaterialStateProperty.all<CircleBorder>(
                                                    CircleBorder(
                                                      side: BorderSide(
                                                        color: Color(0x7f789fff),
                                                      ),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Color(0x7f789fff)
                                                  ),
                                                )
                                                    : ButtonStyle(
                                                  shape: MaterialStateProperty.all<CircleBorder>(
                                                    CircleBorder(
                                                      side: BorderSide(
                                                        color: Color(0xfffbfbfb),
                                                      ),
                                                    ),
                                                  ),
                                                  enableFeedback: false,
                                                  backgroundColor: MaterialStateProperty.all(
                                                      Color(0xfffbfbfb)
                                                  ),
                                                )
                                            )
                                        ),
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
                                      ]
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                      children: [
                                        Container(
                                            height: 47,
                                            child: ElevatedButton(
                                                child: Icon(Boxicons.bx_male_sign,
                                                    color: _pressedButtonMale ? Colors.white : Color (0xb248659e)
                                                ),
                                                onPressed: () => setState(() =>
                                                {
                                                  if (!_pressedButtonFemale)
                                                    {
                                                      if (!_pressedButtonMale)
                                                        {
                                                          _pressedButtonMale = !_pressedButtonMale
                                                        }
                                                    }
                                                  else
                                                    {
                                                      _pressedButtonMale = ! _pressedButtonMale,
                                                      _pressedButtonFemale = !_pressedButtonFemale
                                                    },
                                                  _sex = "Male",
                                                }),
                                                style: _pressedButtonMale
                                                    ? ButtonStyle(
                                                  shape: MaterialStateProperty.all<CircleBorder>(
                                                    CircleBorder(
                                                      side: BorderSide(
                                                        color: Color(0x7f789fff),
                                                      ),
                                                    ),
                                                  ),
                                                  backgroundColor: MaterialStateProperty.all(
                                                      Color(0x7f789fff)
                                                  ),
                                                )
                                                    : ButtonStyle(
                                                  shape: MaterialStateProperty.all<CircleBorder>(
                                                      CircleBorder(
                                                          side: BorderSide(
                                                              color: Color(0xfffbfbfb)
                                                          )
                                                      )
                                                  ),
                                                  enableFeedback: false,
                                                  backgroundColor: MaterialStateProperty.all(
                                                      Color(0xfffbfbfb)
                                                  ),
                                                )
                                            )
                                        ),
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
                                      ]
                                  ),
                                ]
                            ),
                            SizedBox(height: 30),
                            Container(
                              width: 300,
                              child: TextFormField(
                                controller: TextEditingController(
                                    text: _age.toString(),
                                ),
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
                                  labelText: "возраст собаки",
                                  labelStyle: TextStyle(
                                    color: Color(0xb248659e),
                                    fontSize: 12,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.84,
                                  ),
                                ),
                                onChanged: (value) {
                                  _age = int.parse(value);
                                },
                              ),
                            ),
                            SizedBox(height: 15.67),
                            Container(
                              width: 300,
                              child: TextFormField(
                                maxLines: 5,
                                textAlign: TextAlign.left,
                                controller: TextEditingController(
                                    text: _description,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "please enter your dog's description :)";
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
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Color(0xff2c4880),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color(0xb248659e),
                                      width: 1.0,
                                    ),
                                  ),
                                  hoverColor: Color(0xb248659e),
                                  focusColor: Color(0xb248659e),
                                  labelText: "здесь расскажи о твоей собачке :)",
                                  labelStyle: TextStyle(
                                    color: Color(0xb248659e),
                                    fontSize: 12,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.84,
                                  ),
                                ),
                                onChanged: (value) {
                                  _description = value;
                                },
                              ),
                            ),
                            SizedBox(height: 30.67),
                            Container(
                              width: 300,
                              child: SearchableDropdown.single(
                                menuBackgroundColor: Color(0xfffbfbfb),
                                underline: Column(
                                    children: <Widget>[
                                      Divider(
                                          thickness: 1,
                                          height: 3,
                                          color: Color(0xb248659e)),
                                    ]
                                ),
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
                                searchHint: null,
                                dialogBox: false,
                                isExpanded: true,
                                menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(400)),
                                closeButton: "Закрыть",
                                displayClearIcon: false,
                                icon: const Icon(EvaIcons.arrowIosDownward,
                                    color: Color(0xb248659e)
                                ),
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
                                    selectedValue = value;
                                    _breed = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 35.67),
                            SizedBox(
                              width: 300,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  final form = _formKey.currentState;
                                  if (form.validate()) {
                                    _onSaveSettingsButton();
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
                                child: Text(
                                  "Сохранить настройки",
                                  style: TextStyle(
                                    color: Color(0xfffbfbfb),
                                    fontSize: 18,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    )
                )
            )
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
