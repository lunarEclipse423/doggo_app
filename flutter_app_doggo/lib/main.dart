import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/add_dog.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:google_maps/dog_profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps/hello.dart';
import 'input_phone_number.dart';
import 'input_code.dart';
import 'register.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps/person_profile.dart';
import 'package:google_maps/view_person_profile.dart';
//import 'package:google_maps/model/user.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:google_maps/views/chatrooms.dart';
import 'package:google_maps/human_settings.dart';
import 'dog_settings.dart';
import 'tabs_page.dart';
import 'const.dart';

void main() => runApp(App());
//String start = '';

class App extends StatefulWidget {
  _AppState createState() => _AppState();
}

class _AppState extends State<App>
{
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        //initialData: Settings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError || snapshot.data == null)
          {
            return Container(color: Colors.white);
          }
              return FutureBuilder(builder: (context, snapshot) {
                return MyApp();
              });

        }
    );
   }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool auth = false;
    if(FirebaseAuth.instance.currentUser?.uid == null){
      print('\nUser is currently signed out!\n');
           auth = false;
    } else {
      print('\nUser is signed in!\n');
           auth = true;
    }
    print("DONE");
    return FutureBuilder(builder: (context, snapshot) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Geolocation',
        //initialRoute: start,
        home: /*auth ? TabsPage(index : 1) : */WelcomeWindow(),
        routes: {
          '/hello': (BuildContext context) => WelcomeWindow(),
          '/map': (BuildContext context) =>
              Map(FirebaseAuth.instance.currentUser.uid),
          '/chat': (BuildContext context) => ChatRoom(),
          '/dogProfile': (BuildContext context) => DogProfile('user', 'dog'),
          '/inputPhoneNumber': (BuildContext context) =>
              InputPhoneNumberWindow(),
          //  '/inputCode':(BuildContext context) => InputCodeWindow(phoneNumber),
          '/register': (BuildContext context) => RegisterWindow(),
          '/addDog': (BuildContext context) => AddDogWindow(),
          '/personProfile': (BuildContext context) => PersonProfile('uid'),
          '/personProfileView': (BuildContext context) => PersonProfileView(),
          '/humanSettings': (BuildContext context) => HumanSettings('user'),
          '/dogSettings': (BuildContext context) => DogSettings('user', 'dog'),
          '/tabsPage': (BuildContext context) => TabsPage(),
          //тут в общем заводим пути для наших окошек всех
        },
        onGenerateRoute: (routeSettings) {
          var path = routeSettings.name.split('/');

          if (path[1] == "map") {
            return new MaterialPageRoute(
              builder: (context) => new Map(path[2]),
              settings: routeSettings,
            );
          }
          if (path[1] == "addDog") {
            return new MaterialPageRoute(
              builder: (context) => new AddDogWindow(uid: path[2]),
              settings: routeSettings,
            );
          }
          if (path[1] == "dogProfile") {
            return new MaterialPageRoute(
              builder: (context) => new DogProfile(path[2], path[3]),
              settings: routeSettings,
            );
          }
          if (path[1] == "personProfile") {
            return new MaterialPageRoute(
              builder: (context) => new PersonProfile(path[2]),
              settings: routeSettings,
            );
          }
          if (path[1] == "personProfileView") {
            return new MaterialPageRoute(
              builder: (context) => new PersonProfileView(uid: path[2]),
              settings: routeSettings,
            );
          }
          if (path[1] == "humanSettings") {
            return new MaterialPageRoute(
              builder: (context) => new HumanSettings(path[2]),
              settings: routeSettings,
            );
          }
          if (path[1] == "dogSettings") {
            return new MaterialPageRoute(
              builder: (context) => new DogSettings(path[2], path[3]),
              settings: routeSettings,
            );
          }
          if (path[1] == "tabsPage") {
            return new MaterialPageRoute(
              builder: (context) => new TabsPage(index: int.parse(path[2])),
              settings: routeSettings,
            );
          }
        },
      );
    });}
}

class Map extends StatefulWidget {
  final String _currentUid;
  Map(String uid) : _currentUid = uid;
  @override
  _MapState createState() => _MapState();
}

//ну глобальные переменные оч нужны извините мартынов не одобряет
List<DocumentSnapshot> _walkingDogs = [];
bool status = true;
Location _location = new Location();

class _MapState extends State<Map> {
  Completer<GoogleMapController> controller1;
  LocationData _currentLocation;
  final Set<Marker> _markers = {};
  BitmapDescriptor _greenLocationIcon;
  BitmapDescriptor _redLocationIcon;
  //Location _location;
  final List<BitmapDescriptor> _iconNumbers = [];
  static List<DocumentSnapshot> _myDogs = [];
  List<MultiSelectItem<DocumentSnapshot>> _items = [];
  int _selectedIndex = 0;
  OverlayEntry _overlayEntry = OverlayEntry(builder: (context) =>Container(color: Colors.white.withOpacity(0)));

  @override
  void initState() {
    _setCustomMapPin();

    super.initState();

    _getDogsData();
    _getUserData();
    _location.onLocationChanged.listen((LocationData cLoc) {
      _currentLocation = cLoc;
      _updatePinOnMap();
      _updateLocationOnDataBase();
    });
    _setUserData();
  }

  _getUserData() async {
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    status = user.get('status');
    userWalking = user.get('isWalking');
    dogsAmount = user.get('dogsAmount');
  }

  _getDogsData() async {
    final QuerySnapshot result = await writeUser.collection('dogs').get();
    if (mounted) {
      myDogs = result.docs;
      setState(() {
        _items = myDogs
            .map((dog) =>
                MultiSelectItem<DocumentSnapshot>(dog, dog.get('name')))
            .toList();
      });
    }
  }

  _setUserData() async {
    _currentLocation = await _location.getLocation();
    if (mounted) {
      writeUser.update({
        'location':
            GeoPoint(_currentLocation.latitude, _currentLocation.longitude),
      });

    }
  }

  Future _getDogs(List<Widget> dogs, DocumentSnapshot user) async {
    List<DocumentSnapshot> dogsList = (await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('dogs')
        .get())
        .docs;

    dogsList.forEach((element) async {
      if (element.get('isWalking') == true) {
        String dogName = element.get('name');

        String dogImageURL = '';
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('users/' + user.id + '/dogs/' + element.id + '/profile');

        await storageReference
            .getDownloadURL()
            .then((fileURL) => setState(() => dogImageURL = fileURL));

        dogs.add(GestureDetector(
          onTap: () {
            _overlayEntry.remove();
            Navigator.of(context).push(SwipeablePageRoute(
                builder: (BuildContext context) =>
                    DogProfile(user.id, element.id)));
          },
          child: Column(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(dogImageURL),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Text(
                dogName,
                style: TextStyle(
                  color: Color(0xff48659e),
                  fontSize: 13,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.12,
                ),
              ),
            ],
          ),
          // ),
        ));
      }
    });

  }


  _showOverlay(BuildContext context, DocumentSnapshot user) async {
    List<Widget> dogs = [];
    int walkingDogs = user.get('walkingDogs');
    bool finish = false;
    bool start = false;
    while (dogs.length < walkingDogs && finish == false) {
      print('LOADING........');
     // if(start == false) {
        start = true;
        await _getDogs(dogs, user).then((value) =>
            () {
          finish = true;
        });
     // }
    }

    _overlayEntry = OverlayEntry(
        builder: (context) => ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Colors.white.withOpacity(0)),
                enableFeedback: false),
            onPressed: () {
              _overlayEntry?.remove();
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 90.0),
                  height: MediaQuery.of(context).size.height * 0.14,
                  width: MediaQuery.of(context).size.width * 0.53,
                  child: FractionallySizedBox(
                    child: ListView.separated(
                        itemCount: walkingDogs,
                        shrinkWrap: true,
                        //   padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, int index) {
                          return dogs[index];
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 20,
                          );
                        }),
                  ),
                ),
              ),
            )));
    setState(() {
      Overlay.of(context).insert(_overlayEntry);
    });
  }


  void _addMarker(DocumentSnapshot user, String dog)  async {
    int walkingDogs = user.get('walkingDogs');
    _markers.add(Marker(
        markerId: MarkerId(user.id),
        icon:
            user.get('status') == true ? _greenLocationIcon : _redLocationIcon,
        position: LatLng(
            user.get('location').latitude, user.get('location').longitude),
        onTap: () async {
          // Navigator.of(context).push(SwipeablePageRoute(
          //   builder: (BuildContext context) => DogProfile(user.id, dog),
          // ));
          if(walkingDogs == 1) {
            Navigator.of(context).push(SwipeablePageRoute(
                builder: (BuildContext context) =>
                    DogProfile(user.id, dog)));
          }
            else {
            await _showOverlay(context, user);
          }
        }));
    _markers.add(Marker(
      markerId: MarkerId(user.id + "/number"),
      icon: _iconNumbers[walkingDogs - 1],
      position:
          LatLng(user.get('location').latitude, user.get('location').longitude),
    ));

    setState(() {});
  }

  void _updateLocationOnDataBase() async {
    writeUser.update({
      'location':
          GeoPoint(_currentLocation.latitude, _currentLocation.longitude)
    });
  }

  void _updatePinOnMap() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').get();
    final List<DocumentSnapshot> documents = result.docs;

    documents.forEach((data) async {
      if (data.get('isWalking') == true) {
        final QuerySnapshot dogs = await FirebaseFirestore.instance
            .collection('users')
            .doc(data.id)
            .collection('dogs')
            .get();
        final List<DocumentSnapshot> docDogs = dogs.docs;
        if (mounted) {
          for (int i = 0; i < docDogs.length; i++) {
            if (docDogs[i].get('isWalking') == true) {
              _addMarker(data, docDogs[i].id);
              break;
            }
          }
        }
      }
    });
  }

  void _setCustomMapPin() async {
    _greenLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/geo_icon_green.png');
    _redLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/geo_icon_red.png');
    for (int i = 0; i < 9; ++i) {
      _iconNumbers.add(await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5),
          'assets/${(i + 1).toString()}.png'));
    }
  }

  void _onWalkButtonPressed() async {
    final CollectionReference writeDogs = writeUser.collection('dogs');

    if (mounted) {
      setState(() {
        if (userWalking == true && _walkingDogs.length > 0) {
          writeUser
              .update({'isWalking': (false)})
              .then((value) => print("Walk status changed"))
              .catchError(
                  (error) => print("Failed to change walk status: $error"));
          userWalking = false;
          _markers.removeWhere((m) => m.markerId.value == widget._currentUid);
          _markers.removeWhere(
              (m) => m.markerId.value == (widget._currentUid + "/number"));
          _walkingDogs.forEach((element) {
            writeDogs.doc(element.id).update({'isWalking': false});
          });

          _walkingDogs.clear();
          writeUser.update({'walkingDogs': 0});
        } else {
          print("КОЛ СОБАК " + myDogs.length.toString());
          if (myDogs.length > 1) {
            _showMultiSelect(context);
          } else if (myDogs.length == 1) {
            _walkingDogs.add(myDogs[0]);
            writeUser
                .update({'isWalking': (true)})
                .then((value) => print("Walk status changed"))
                .catchError(
                    (error) => print("Failed to change walk status: $error"));
            userWalking = true;
            writeUser
                .collection('dogs')
                .doc(_walkingDogs[0].id)
                .update({'isWalking': true});
            writeUser.update({'walkingDogs': 1});
            _showScaffold("Вы пошли гулять с ${_walkingDogs[0].get('name')}!");
            _updatePinOnMap();
          } else {
            //вообще нет собак
            _showScaffold("Гулять пока не с кем...");
          }
        }
        //personProfile.createState();

      });
    }

  }

  _showScaffold(String massage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          massage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xe5ffffff),
            fontSize: 20,
            fontFamily: "Roboto",
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Color(0xe852a8f7),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showMultiSelect(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      builder: (ctx) {
        return MultiSelectBottomSheet(
          listType: MultiSelectListType.CHIP,
          //minChildSize:50,
          maxChildSize: 0.4,
          minChildSize: 0.15,
          initialChildSize: 0.23,
          selectedColor: Color(0xffee870d),
          unselectedColor: Color(0xe852a8f7),
          itemsTextStyle: TextStyle(
            color: Color(0xe5ffffff),
            fontSize: 18,
            fontFamily: "Roboto",
            fontWeight: FontWeight.w700,
          ),
          selectedItemsTextStyle: TextStyle(
            color: Color(0xe5ffffff),
            fontSize: 18,
            fontFamily: "Roboto",
            fontWeight: FontWeight.w700,
          ),
          cancelText: Text(
            "Закрыть",
            style: TextStyle(
              color: Color(0xff48659e),
              fontSize: 18,
              fontFamily: "Roboto",
              fontWeight: FontWeight.w700,
            ),
          ),
          confirmText: Text(
            "ОК",
            style: TextStyle(
              color: Color(0xff48659e),
              fontSize: 18,
              fontFamily: "Roboto",
              fontWeight: FontWeight.w700,
            ),
          ),
          title: Container(
            alignment: Alignment.center,
            child: Text(
              "С кем идём гулять?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff48659e),
                fontSize: 20,
                fontFamily: "Roboto",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          items: _items,
          //initialValue: _items,
          onConfirm: (values) {
              _walkingDogs = values;
              if (_walkingDogs.isEmpty) {
                _showScaffold("Собака не выбрана :(");
              } else {
                writeUser
                    .update({'isWalking': (true)})
                    .then((value) => print("Walk status changed"))
                    .catchError((error) =>
                        print("Failed to change walk status: $error"));
                userWalking = true;
                _walkingDogs.forEach((element) {
                  writeUser
                      .collection('dogs')
                      .doc(element.id)
                      .update({'isWalking': true});
                });
                writeUser.update({'walkingDogs': _walkingDogs.length});
                _updatePinOnMap();
              }
              setState(() {
            });
          },
        );
      },
    );
  }

  Widget _dogStatus = status == true
      ? SvgPicture.asset('assets/good.svg')
      : SvgPicture.asset('assets/bad.svg');
  final Widget GoodDogIcon = SvgPicture.asset('assets/good.svg');
  final Widget BadDogIcon = SvgPicture.asset('assets/bad.svg');

  void _onChangeStatusButtonPressed() {
    if (status == true) {
      _dogStatus = BadDogIcon;
      writeUser.update({'status': false});
      status = false;
    } else {
      _dogStatus = GoodDogIcon;
      writeUser.update({'status': true});
      status = true;
    }
    //дальше обновляем прорисовку марки
    _markers.removeWhere((m) =>
        m.markerId.value == widget._currentUid); //удаление прорисованной марки
    _markers.removeWhere((m) =>
        m.markerId.value ==
        widget._currentUid + "/number"); //удаление прорисованной марки
    //и прорисовываем:
    if (mounted) {
      if (userWalking == true) {
        _updatePinOnMap();
        // _markers.add(Marker(
        //     markerId: MarkerId(widget._currentUid),
        //     icon: _status == true ? _greenLocationIcon : _redLocationIcon,
        //     position:
        //         LatLng(_currentLocation.latitude, _currentLocation.longitude),
        //     onTap: () {
        //       Navigator.of(context).push(SwipeablePageRoute(
        //         builder: (BuildContext context) =>
        //             DogProfile(widget._currentUid, _walkingDogs.first.id),
        //       ));
        //     }));
        // _markers.add(Marker(
        //   markerId: MarkerId(widget._currentUid + "/number"),
        //   icon: _iconNumbers[_walkingDogs.length - 1],
        //   position:
        //       LatLng(_currentLocation.latitude, _currentLocation.longitude),
        // ));
      }
    }
    setState(() {});
  }

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onChatButtonPressed() {
    setState(() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatRoom()));
    });
  }

  void _onHomeButtonPressed() {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PersonProfile(widget._currentUid,
                  )));
    });
  }

  _onCameraMove(CameraPosition position) {}

  Widget mapButton(Function function, Icon icon, Color color) {
    return RawMaterialButton(
      onPressed: function,
      child: icon,
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: color,
      padding: const EdgeInsets.all(7.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     /* bottomNavigationBar:
          BottomNavigationBar(items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(PhosphorIcons.chats_circle, color: Color(0xe852a8f7), size: 50),
                label: ''),
        BottomNavigationBarItem(
            icon: Icon(Boxicons.bx_home, color: Color(0xe852a8f7), size: 50),
            label: ''),
        BottomNavigationBarItem(
            icon: Icon(Boxicons.bx_world, color: Color(0xe852a8f7), size: 50),
            label: ''),
      ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xff7e5729),
            backgroundColor: Color(0xe5ffffff),
            onTap: _onItemTapped,
            ),*/
      body: _currentLocation == null
          ? Stack(children: [
              Center(
                child: Text(
                  'loading map..',
                  style: TextStyle(
                      fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
                ),
              ),
            ])
          : Container(
              child: Stack(children: <Widget>[
                GoogleMap(
                  markers: _markers,
                  mapType: _currentMapType,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        _currentLocation.latitude, _currentLocation.longitude),
                    zoom: 14.4746,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    setState(() {
                      _updatePinOnMap();
                    });
                  },
                  zoomGesturesEnabled: true,
                  onCameraMove: _onCameraMove,
                  myLocationEnabled: false,
                  compassEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0.0, 50.0, 7.0, 0.0),
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 86,
                          icon: Container(
                            width: 54.18,
                            height: 40,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 54.18,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x3f53a8f8),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    color: Color(0xd8ffffff),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          child: Icon(Boxicons.bx_merge,
                                              color: Color(0xff52a8f7),
                                              size: 33)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: _onMapTypeButtonPressed),
                    )),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(0.0, 70.0, 7.0, 0.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 63.49,
                            padding: const EdgeInsets.all(0.0),
                            child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 86,
                                icon: Container(
                                  width: 86,
                                  height: 63.49,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 86,
                                        height: 63.49,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x3f53a8f8),
                                              blurRadius: 4,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                          color: Color(0xd8ffffff),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                                child: Icon(Elusive.guidedog,
                                                    color: Color(0xff52a8f7),
                                                    size: 50)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: _onWalkButtonPressed),
                          ),
                          Container(
                            height: 80.49,
                            padding: const EdgeInsets.all(0.0),
                            child: IconButton(
                                iconSize: 86,
                                icon: Container(
                                  width: 86,
                                  height: 63.49,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 86,
                                        height: 63.49,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x3f53a8f8),
                                              blurRadius: 4,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                          color: Color(0xd8ffffff),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: _dogStatus,
                                              //     image: _dogStatus
                                              // )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: _onChangeStatusButtonPressed),
                          ),
                        ],
                      )),
                ),
                /*Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 303.81,
                    height: 68,
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3f53a8f8),
                          blurRadius: 3,
                          offset: Offset(0, 4),
                        ),
                      ],
                      color: Color(0xe5ffffff),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(PhosphorIcons.chats_circle,
                                color: Color(0xe852a8f7)),
                            iconSize: 52,
                            //padding: ,
                            onPressed: _onChatButtonPressed),
                        *//*Container(
                              padding: const EdgeInsets.all(0.0),
                              width: 35.10,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Boxicons.bx_search,
                                      color: Color(0xe852a8f7)),
                                  iconSize: 50,
                                  //padding: ,
                                  onPressed: _onWalkButtonPressed)),*//*
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Boxicons.bx_world,
                                color: Color(0xff7e5729)),
                            iconSize: 50),
                        //onPressed: _onWalkButtonPressed),
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Boxicons.bx_home,
                                color: Color(0xe852a8f7)),
                            iconSize: 50,
                            //padding: ,
                            onPressed: _onHomeButtonPressed),
                      ],
                    ),
                  ),
                ),*/
              ]),
            ),
    );
  }
}
