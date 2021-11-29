import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps/person_profile.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'input_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:google_maps/const.dart';
<<<<<<< Updated upstream
=======
import 'package:shared_preferences/shared_preferences.dart';
import 'helper/helper_functions.dart';

>>>>>>> Stashed changes

class HumanSettings extends StatefulWidget {
  final String _currentUid;

  HumanSettings(String uid) : _currentUid = uid;

  @override
  _HumanSettingsState createState() => _HumanSettingsState();
}

class _HumanSettingsState extends State<HumanSettings> {
  OverlayEntry _overlayEntry;

  String _name;
  final _formKey = GlobalKey<FormState>();
  String _humanImageURL;

  bool isPicked = false;
  bool isCropped = false;
  final cropKey = GlobalKey<CropState>();

  File sampleImage;
  File personImage;

  List<Widget> _dogs = [];

  void initState() {
    super.initState();
    _getHumanData();
    _getDogs();
  }

  void _getHumanData() async {
    String humanImageURL = '';
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/' + widget._currentUid + '/profile');

    await storageReference
        .getDownloadURL()
        .then((loc) => setState(() => humanImageURL = loc));

    String name = (await FirebaseFirestore.instance
            .collection('users')
            .doc(widget._currentUid)
            .get())
        .get('name');

    setState(() {
      _name = name;
      _humanImageURL = humanImageURL;
    });
  }

  void _getDogs() async {
    List<DocumentSnapshot> dogsList = (await FirebaseFirestore.instance
            .collection('users')
            .doc(widget._currentUid)
            .collection('dogs')
            .get())
        .docs;

    List<Widget> dogs = [];

    dogsList.forEach((element) async {
      String dogName = element.get('name');
      String dogBreed = element.get('breed');
      String dogSex = element.get('sex');
      String dogAge = element.get('age').toString();

      String dogImageURL = '';
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'users/' + widget._currentUid + '/dogs/' + element.id + '/profile');

      await storageReference
          .getDownloadURL()
          .then((fileURL) => setState(() => dogImageURL = fileURL));

      dogs.add(Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: SizedBox(
          // height: 110,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(Colors.white.withOpacity(0)),
              foregroundColor:
              MaterialStateProperty.all(Colors.white.withOpacity(0)),
              overlayColor:
              MaterialStateProperty.all(Colors.white.withOpacity(0)),
              shadowColor:
              MaterialStateProperty.all(Colors.white.withOpacity(0)),
            ),
            child: Row(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(dogImageURL),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        dogName,
                        style: TextStyle(
                          color: Color(0xff48659e),
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.12,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        dogBreed,
                        maxLines: 2,
                        style: TextStyle(
                          color: Color(0xff48659e),
                          fontSize: 14,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.98,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        (dogSex == "Male" ? "мальчик, " : "девочка, ") +
                            dogAge,
                        style: TextStyle(
                          color: Color(0xff48659e),
                          fontSize: 14,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.98,
                        ),
                      )
                    ]),
              ],
            ),
            onPressed: () {
              _overlayEntry.remove();
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dogSettings/${widget._currentUid}/${element.id}',
                      (route) => false);
            },
          ),
        ),
      ));
    });

    setState(() {
      _dogs = dogs;
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
    });
  }

  void _onSaveSettingsPressed() async {
<<<<<<< Updated upstream
    final DocumentReference user =
    FirebaseFirestore.instance.collection('users').doc(widget._currentUid);

=======
>>>>>>> Stashed changes
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/' + widget._currentUid + '/profile');

    if (personImage != null) {
      UploadTask uploadTask = storageReference.putFile(personImage);
      print('File Uploaded');
    }
<<<<<<< Updated upstream

    user.update({
      'name': _name,
    });

    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PersonProfile(widget._currentUid)));
=======
    writeUser.update({
      'name': _name
    });
    HelperFunctions.saveUserNameSharedPreference(_name);
    setState(() {
      Navigator.pushNamedAndRemoveUntil(context, '/tabsPage/2', (route)=>false);
>>>>>>> Stashed changes
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      return ((isPicked == true && isCropped == false)
          ? _buildCropWidget()
          : _buildSettingsWidget());
    } on Exception catch (e) {
      print('error caught: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);
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

  Widget _buildSettingsWidget() {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Container(
              //margin: EdgeInsets.fromLTRB(0.0, 100, 0.0, 0.0),
                child: Builder(
                    builder: (context) => Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  "профиля",
                                  style: TextStyle(
                                    color: Color(0xb248659e),
                                    fontSize: 20,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.26,
                                  ),
                                ),
                                SizedBox(height: 20),
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
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 125,
                                        width: 125,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: (_humanImageURL == null
                                                ? AssetImage('assets/sleep_dog.gif')
                                                : (personImage == null
                                                ? CachedNetworkImageProvider(
                                                _humanImageURL)
                                                : FileImage(personImage))),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      )),
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
                                SizedBox(height: 88.67),
                                Container(
                                  width: 300,
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: _name,
                                    ),
                                    style: TextStyle(
                                      color: Color(0xff2c4880),
                                      fontSize: 14,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.84,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "имя",
                                      labelStyle: TextStyle(
                                        color: Color(0xb248659e),
                                        fontSize: 14,
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.84,
                                      ),
                                      border: UnderlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Invalid name';
                                      }
                                    },
                                    onChanged: (input) {
                                      _name = input;
                                    },
                                  ),
                                ),
                                SizedBox(height: 60),

                                Container(
                                  width: MediaQuery.of(context).size.width / 1.15,
                                  height: 60,
                                  child:
                                  ElevatedButton(
                                    onPressed: () {
                                      _showOverlay(context);
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            Color(0xff789fff)),
                                        foregroundColor: MaterialStateProperty.all(
                                          Color(0xff789fff),
                                        ),
                                        overlayColor: MaterialStateProperty.all(
                                            Color(0xff789fff)),
                                        shadowColor: MaterialStateProperty.all(
                                            Color(0xff789fff)),
                                        //elevation: MaterialStateProperty.all(20),
                                        side: MaterialStateProperty.all(BorderSide(
                                            style: BorderStyle.none,
                                            color: Color(0xff789fff))),
                                        enableFeedback: false,
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(22),
                                                side: BorderSide(
                                                    color: Color(0xff789fff))))
                                      //shape: MaterialStateProperty.all(O)
                                    ),
                                    child: Text(
                                      "Редактировать собаку",
                                      style: TextStyle(
                                        color: Color(0xfffbfbfb),
                                        fontSize: 20,
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: MediaQuery.of(context).size.width / 1.15,
                                  height: 60,
                                  child:
                                  ElevatedButton(
                                    onPressed: () {
                                      final form = _formKey.currentState;
                                      if (form.validate()) {
                                        _onSaveSettingsPressed();
                                      }
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            defaultOrange),
                                        foregroundColor: MaterialStateProperty.all(
                                          defaultOrange,
                                        ),
                                        overlayColor: MaterialStateProperty.all(
                                            defaultOrange),
                                        shadowColor: MaterialStateProperty.all(
                                            defaultOrange),
                                        //elevation: MaterialStateProperty.all(20),
                                        side: MaterialStateProperty.all(BorderSide(
                                            style: BorderStyle.none,
                                            color: defaultOrange)),
                                        enableFeedback: false,
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(22),
                                                side: BorderSide(
                                                    color: defaultOrange)))
                                      //shape: MaterialStateProperty.all(O)
                                    ),
                                    child: Text(
                                      "Сохранить изменения",
                                      style: TextStyle(
                                        color: Color(0xfffbfbfb),
                                        fontSize: 20,
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            )))))));
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

  _showOverlay(BuildContext context) async {
    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange[300],
                    Colors.orange[200],
                    Colors.orange[100]
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.fromLTRB(0.0, 100, 0.0, 50),
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  Material(
                    color: Colors.white.withOpacity(0),
                    shadowColor: Colors.white.withOpacity(0),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Text(
                        "Чей профиль редактировать?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff2c4880),
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(0.0, 10, 0.0, 50),
                      scrollDirection: Axis.vertical,
                      children: _dogs.toList(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size(250, 50),
                      ),
                      onPressed: () {
                        _overlayEntry.remove();
                        Navigator.pushNamedAndRemoveUntil(context,
                            '/addDog/${widget._currentUid}', (route) => false);
                      },
                      child: Text(
                        "Добавить собаку",
                        style: TextStyle(
                          color: Color(0xfffbfbfb),
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xffee870d),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size(100, 30),
                      ),
                      onPressed: () {
                        _overlayEntry.remove();
                      },
                      child: Text(
                        "закрыть",
                        style: TextStyle(
                          color: Color(0xff535866),
                          fontSize: 14,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );

    Overlay.of(context).insert(_overlayEntry);
  }
}
