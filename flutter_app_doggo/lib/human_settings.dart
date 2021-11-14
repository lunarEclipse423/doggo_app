import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
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

class HumanSettings extends StatefulWidget {
  final String _currentUid;

  HumanSettings(String uid)
      : _currentUid = uid;

  @override
  _HumanSettingsState createState() => _HumanSettingsState();
}

class _HumanSettingsState extends State<HumanSettings> {
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

    String name = (await FirebaseFirestore.instance.collection('users').doc(widget._currentUid).get()).get('name');

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
        .get()).docs;

    List<Widget> dogs = [];

    dogsList.forEach((element) async {
      String dogName = element.get('name');

      String dogImageURL = '';
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'users/' + widget._currentUid + '/dogs/' + element.id + '/profile');

      await storageReference
          .getDownloadURL()
          .then((fileURL) => setState(() => dogImageURL = fileURL));

      dogs.add(
          SizedBox(
            height: 100,
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
                side: MaterialStateProperty.all(
                    BorderSide(
                      width: 1,
                      style: BorderStyle.none,
                      color: Color(0xfffbfbfb)
                    )
                ),
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
              child: Row(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(dogImageURL),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 180,
                    height: 69,
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                dogName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xff48659e),
                                  fontSize: 18,
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.12,
                                ),
                              ),
                            ]
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/dogSettings/${widget._currentUid}/${element.id}', (route) => false);
              },
            ),
          )
      );
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
    final DocumentReference user = FirebaseFirestore.instance
        .collection('users')
        .doc(widget._currentUid);

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/' + widget._currentUid + '/profile');

    if (personImage != null) {
      UploadTask uploadTask = storageReference.putFile(personImage);
      print('File Uploaded');
    }

    user.update({
      'name': _name,
    });

    setState(() {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => PersonProfile(uid: widget._currentUid)));
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
                    builder: (context) =>
                        Form(
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
                                                Color(0xfffbfbfb)
                                            ),
                                            foregroundColor: MaterialStateProperty.all(
                                              Color(0xfffbfbfb),
                                            ),
                                            overlayColor: MaterialStateProperty.all(
                                                Color(0xfffbfbfb)
                                            ),
                                            shadowColor: MaterialStateProperty.all(
                                                Color(0xfffbfbfb)
                                            ),
                                            //elevation: MaterialStateProperty.all(20),
                                            side: MaterialStateProperty.all(
                                                BorderSide(
                                                    width: 155,
                                                    style: BorderStyle.none,
                                                    color: Color(0xfffbfbfb)
                                                )
                                            ),
                                            enableFeedback: false,
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                                side: BorderSide(
                                                    color: Color(0x59c2d1f5)
                                                ),
                                              ),
                                            ),
                                          ),
                                          onPressed: _onAddPhotoButtonPressed,
                                          child:
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 125,
                                                  width: 125,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: (_humanImageURL == null
                                                          ? AssetImage('assets/sleep_dog.gif')
                                                          : (personImage == null
                                                            ? NetworkImage(_humanImageURL)
                                                            : FileImage(personImage))),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                          )
                                      ),
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
                                    SizedBox(height: 40),
                                    // КНОПКА "ПРОДОЛЖИТЬ"
                                    TextButton(
                                      onPressed: () {
                                        final form = _formKey.currentState;
                                        if (form.validate()) {
                                          _onSaveSettingsPressed();
                                        }
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: 238,
                                                minHeight: 51,
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(20),
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
                                            "Сохранить настройки профиля",
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
                                      onPressed: () {
                                        _showOverlay(context);
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: 238,
                                                minHeight: 51,
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(20),
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
                                            "Редактировать профили собак",
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
                                  ],)
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
                  style: Theme
                      .of(context)
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
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) =>
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
            ),
            child: Center(
              child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 50, 0.0, 50),
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: _dogs.toList(),
                ),
              ),
            )
          )
    );

    print('overlayEntry made');

    Overlay.of(context).insert(overlayEntry);

    print('overlayEntry insert');

    await Future.delayed(Duration(seconds: 5));

    print('overlayEntry finish');

    overlayEntry.remove();
  }
}
