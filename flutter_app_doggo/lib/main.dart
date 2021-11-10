import 'dart:async';
import 'dart:io';
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


void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp();
    return FutureBuilder(
        builder: (context, snapshot) {
          return MyApp();
        }
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Geolocation',
      initialRoute: '/',
      routes: {
        '/':(BuildContext context) => WelcomeWindow(),
        '/map':(BuildContext context) => Map(),
        '/dogProfile':(BuildContext context) => DogProfile(),
        '/inputPhoneNumber':(BuildContext context) => InputPhoneNumberWindow(),
        //  '/inputCode':(BuildContext context) => InputCodeWindow(phoneNumber),
        '/register':(BuildContext context) => RegisterWindow(),
        '/addDog':(BuildContext context) => AddDogWindow(),
        //тут в общем заводим пути для наших окошек всех
      },
      onGenerateRoute: (routeSettings){
        var path = routeSettings.name.split('/');

        if (path[1] == "map") {
          return new MaterialPageRoute(
            builder: (context) => new Map(uid:path[2]),
            settings: routeSettings,
          );
        }
      },
    );
  }
}

class Map extends StatefulWidget {
  final String _currentUid;
  Map({String uid}):_currentUid = uid;
  @override
  _MapState createState() => _MapState();
}

class Walk extends StatefulWidget {
  @override
  _WalkState createState() => _WalkState();
}

class _WalkState extends State<Walk> {
  @override
  Widget build(BuildContext context) {
    //что-то на собачьем...
    //хз может по-другому надо будет сделать, а не состоянием
  }
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> controller1;
  LocationData _currentLocation;
  final Set<Marker> _markers = {};
  BitmapDescriptor _greenLocationIcon;
  BitmapDescriptor _redLocationIcon;
  Location _location;

  @override
  void initState() {
    super.initState();
    _location = new Location();
    _location.onLocationChanged.listen((LocationData cLoc) {
      _currentLocation = cLoc;
      _updatePinOnMap();
      _updateLocationOnDataBase();
    });
    _setUserData();
    _setCustomMapPin();
  }

  void _addMarker(DocumentSnapshot user)
  {
    _markers.add(
        Marker(
            markerId: MarkerId(user.id),
            icon: user.get('status') == true ? _greenLocationIcon : _redLocationIcon,
            position: LatLng(user
                .get('location')
                .latitude, user
                .get('location')
                .longitude),
            onTap: () {
              Navigator.of(context).push(SwipeablePageRoute(
                builder: (BuildContext context) => DogProfile(),
              ));
            })
    );
  }

  void _updateLocationOnDataBase() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users
        .doc(widget._currentUid)
        .update({
      'location': GeoPoint(_currentLocation.latitude, _currentLocation.longitude)
    });
  }

  void _updatePinOnMap() async
  {
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<DocumentSnapshot> documents = result.docs;
    setState(() {
      documents.forEach((data) {
        _markers.removeWhere((m)=>m.markerId.value == data.id);
        if (data.get('isWalking') == true) {
          _addMarker(data);
        }
      }
      );
    });
  }

  void _setUserData() async {
    _currentLocation = await _location.getLocation();
    final DocumentReference user = FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid);
    user.update({
      'location': GeoPoint(_currentLocation.latitude, _currentLocation.longitude),
      'isWalking': false,
      'status' : true
    });
    setState(() {});
  }

  void _setCustomMapPin() async {
    _greenLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/geo_icon_green.png');
    _redLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/geo_icon_red.png');
  }

  void _onWalkButtonPressed() async {
    final DocumentSnapshot readUser = await FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid).get();
    final DocumentReference writeUser = FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid);
    setState(() {
      writeUser.update({
        'isWalking': (readUser.get('isWalking') == true ? false : true)
      })
          .then((value) => print("Walk status changed"))
          .catchError((error) => print("Failed to change walk status: $error"));
      if(readUser.get('isWalking') == true)
      {
        _markers.removeWhere((m)=>m.markerId.value == readUser.id);
      }
      else
      {
        _addMarker(readUser);
      }
    });
  }

  Widget _dogStatus =  SvgPicture.asset('assets/good.svg');
  final Widget GoodDogIcon = SvgPicture.asset('assets/good.svg');
  final Widget BadDogIcon = SvgPicture.asset('assets/bad.svg');

  void _onChangeStatusButtonPressed() async {
    final DocumentReference writeUser = FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid);

    if (_dogStatus == GoodDogIcon)
    {
      _dogStatus = BadDogIcon;
      writeUser.update({'status' : false});
    }
    else
    {
      _dogStatus = GoodDogIcon;
      writeUser.update({'status' : true});
    }
    //дальше обновляем прорисовку марки
    _markers.removeWhere((m)=>m.markerId.value == widget._currentUid); //удаление прорисованной марки
    //и прорисовываем:
    final DocumentSnapshot readUser = await FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid).get();
    if (readUser.get('isWalking') == true) {
      _markers.add(
          Marker(
              markerId: MarkerId(widget._currentUid),
              icon: readUser.get('status') == true ? _greenLocationIcon : _redLocationIcon,
              position: LatLng(
                  _currentLocation.latitude, _currentLocation.longitude),
              onTap: () {
                Navigator.of(context).push(SwipeablePageRoute(
                  builder: (BuildContext context) => DogProfile(),
                ));
              })
      );
    }
    setState(() {
    });

  }

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onCameraMove(CameraPosition position) {
  }

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
      body: _currentLocation == null
          ? Container(
        child: Center(
          child: Text(
            'loading map..',
            style: TextStyle(
                fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
          ),
        ),
      )
          : Container(
        child: Stack(children: <Widget>[
          GoogleMap(
            markers: _markers,
            mapType: _currentMapType,
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
              zoom: 14.4746,
            ),
            onMapCreated: (GoogleMapController controller) async {
              final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
              final List<DocumentSnapshot> documents = result.docs;
              setState(() {
                documents.forEach((data) {
                  if (data.get('isWalking') == true) {
                    _addMarker(data);
                  }
                }
                );
              });},
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
              child: Container(
                width: 303.81,
                height: 68,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 303.81,
                      height: 68,
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
                      padding: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(0.0),
                              width: 35.10,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(PhosphorIcons.chats_circle,
                                      color: Color(0xe852a8f7)),
                                  iconSize: 52,
                                  //padding: ,
                                  onPressed: _onWalkButtonPressed)),
                          SizedBox(width: 30.35),
                          Container(
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
                                  onPressed: _onWalkButtonPressed)),
                          SizedBox(width: 30.35),
                          Container(
                              padding: const EdgeInsets.all(0.0),
                              width: 35.10,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Boxicons.bx_world,
                                      color: Color(0xff7e5729)),
                                  iconSize: 50,
                                  onPressed: _onWalkButtonPressed)),
                          SizedBox(width: 30.35),
                          Container(
                              padding: const EdgeInsets.all(0.0),
                              width: 35.10,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Boxicons.bx_home,
                                      color: Color(0xe852a8f7)),
                                  iconSize: 50,
                                  //padding: ,
                                  onPressed: _onWalkButtonPressed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}