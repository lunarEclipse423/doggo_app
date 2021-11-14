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
import 'package:google_maps/person_profile.dart';
import 'package:google_maps/view_person_profile.dart';
//import 'package:google_maps/model/user.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:google_maps/views/chatrooms.dart';
import 'package:google_maps/human_settings.dart';
import 'dog_settings.dart';

void main() => runApp(App());
String start = "";
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    WidgetsFlutterBinding.ensureInitialized();
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
        '/dogProfile':(BuildContext context) => DogProfile('user', 'dog'),
        '/inputPhoneNumber':(BuildContext context) => InputPhoneNumberWindow(),
        //  '/inputCode':(BuildContext context) => InputCodeWindow(phoneNumber),
        '/register':(BuildContext context) => RegisterWindow(),
        '/addDog':(BuildContext context) => AddDogWindow(),
        '/personProfile': (BuildContext context) => PersonProfile(),
        '/personProfileView': (BuildContext context) => PersonProfileView(),
        '/humanSettings': (BuildContext context) => HumanSettings('user'),
        '/dogSettings': (BuildContext context) => DogSettings('user','dog'),
        //тут в общем заводим пути для наших окошек всех
      },
      onGenerateRoute: (routeSettings) {
        var path = routeSettings.name.split('/');

        if (path[1] == "map") {
          return new MaterialPageRoute(
            builder: (context) => new Map(uid:path[2]),
            settings: routeSettings,
          );
        }
        if (path[1] == "addDog") {
          return new MaterialPageRoute(
            builder: (context) => new AddDogWindow(uid:path[2]),
            settings: routeSettings,
          );
        }
        if(path[1] == "dogProfile"){
          return new MaterialPageRoute(
              builder: (context) => new DogProfile(path[2], path[3]),
        settings: routeSettings,
          );
        }
        if(path[1] == "personProfile"){
          return new MaterialPageRoute(
            builder: (context) => new PersonProfile(uid:path[2]),
            settings: routeSettings,
          );
        }
        if(path[1] == "personProfileView"){
          return new MaterialPageRoute(
            builder: (context) => new PersonProfileView(uid:path[2]),
            settings: routeSettings,
          );
        }
        if(path[1] == "humanSettings"){
          return new MaterialPageRoute(
            builder: (context) => new HumanSettings(path[2]),
            settings: routeSettings,
          );
        }
        if(path[1] == "dogSettings"){
          return new MaterialPageRoute(
            builder: (context) => new DogSettings(path[2], path[3]),
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

//ну глобальные переменные оч нужны извините мартынов не одобряет
List<DocumentSnapshot> _walkingDogs = [];
bool _isWalking = false;
bool _status = true;


class _MapState extends State<Map> {
  Completer<GoogleMapController> controller1;
  LocationData _currentLocation;
  final Set<Marker> _markers = {};
  BitmapDescriptor _greenLocationIcon;
  BitmapDescriptor _redLocationIcon;
  Location _location;
  final List<BitmapDescriptor> _iconNumbers = [];
  DocumentReference _writeUser;
  static List<DocumentSnapshot> _myDogs = [];
  List<MultiSelectItem<DocumentSnapshot>> _items = [];

  @override
  void initState() {
    _writeUser = FirebaseFirestore.instance.collection('users')
        .doc(widget._currentUid);
    _setCustomMapPin();
    super.initState();
    _setUserData();
    _getDogsData();
    _getUserData();
    _location = new Location();
    _location.onLocationChanged.listen((LocationData cLoc) {
      _currentLocation = cLoc;
      _updatePinOnMap();
      _updateLocationOnDataBase();
    });
  }

  _getUserData() async
  {
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get();
      _status = user.get('status');
      _isWalking = user.get('isWalking');
  }

  _getDogsData() async
  {
    final QuerySnapshot result = await _writeUser.collection('dogs').get();
    if(mounted) {
      _myDogs = result.docs;
      setState(() {
        _items = _myDogs.map((dog) => MultiSelectItem<DocumentSnapshot>(dog, dog.get('name'))).toList();
      });
    }
  }
  
  void _setUserData() async {
    _currentLocation = await _location.getLocation();
    if(mounted) {
      _writeUser.update({
        'location': GeoPoint(_currentLocation.latitude, _currentLocation.longitude),
      });
     
      setState(() {});
    }
  }

  void _addMarker(DocumentSnapshot user, String dog)
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
                builder: (BuildContext context) => DogProfile(user.id, dog),
              ));
            })
    );
    _markers.add(
        Marker(
          markerId: MarkerId(user.id + "/number"),
          icon: _iconNumbers[user.get('walkingDogs') - 1],
          position: LatLng(user
              .get('location')
              .latitude, user
              .get('location')
              .longitude),
        )
    );

      setState(() {
        });
  }

  void _updateLocationOnDataBase() async {
    _writeUser.update({
      'location': GeoPoint(_currentLocation.latitude, _currentLocation.longitude)
    });
  }

  void _updatePinOnMap() async
  {
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<DocumentSnapshot> documents = result.docs;

    documents.forEach((data) async {
      if (data.get('isWalking') == true) {
        final QuerySnapshot dogs = await FirebaseFirestore.instance.collection('users').doc(data.id).collection('dogs').get();
        final List<DocumentSnapshot> docDogs = dogs.docs;
        if(mounted) {
          for(int i = 0; i < docDogs.length; i++)
            {
              if(docDogs[i].get('isWalking') == true)
              {
                _addMarker(data, docDogs[i].id);
                break;
              }
            }
        }
      }
    }
    );
  }



  void _setCustomMapPin() async {
    _greenLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/geo_icon_green.png');
    _redLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/geo_icon_red.png');
    for(int i = 0; i < 9; ++i) {
      _iconNumbers.add(await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5),
          'assets/${(i+1).toString()}.png'));
    }
  }

  void _onWalkButtonPressed() async {
    final CollectionReference writeDogs = _writeUser.collection('dogs');

    if(mounted)
      {
        setState(() {

          if(_isWalking == true && _walkingDogs.length > 0)
          {
            _writeUser.update({
              'isWalking': (false)
            })
                .then((value) => print("Walk status changed"))
                .catchError((error) => print("Failed to change walk status: $error"));
            _isWalking = false;
            _markers.removeWhere((m)=>m.markerId.value == widget._currentUid);
            _markers.removeWhere((m)=>m.markerId.value == (widget._currentUid + "/number"));
            _walkingDogs.forEach((element) {
              writeDogs.doc(element.id).update({'isWalking' : false});
            });

            _walkingDogs.clear();
            _writeUser.update({'walkingDogs' : 0});
          }
          else
          {
            print("КОЛ СОБАК "+_myDogs.length.toString());
            if(_myDogs.length > 1) {
              _showMultiSelect(context);
            }
            else if(_myDogs.length == 1)
              {
                _walkingDogs.add(_myDogs[0]);
                _writeUser.update({
                  'isWalking': (true)
                })
                    .then((value) => print("Walk status changed"))
                    .catchError((error) => print("Failed to change walk status: $error"));
                _isWalking = true;
                _writeUser.collection('dogs').doc(_walkingDogs[0].id).update(
                      {'isWalking': true});
                _writeUser.update({'walkingDogs': 1});
                _showScaffold("Вы пошли гулять с ${_walkingDogs[0].get('name')}!");
                _updatePinOnMap();
              }
            else
              {
                //вообще нет собак
                _showScaffold("Гулять пока не с кем...");
              }
          }
        });
      }
  }

  _showScaffold(String massage)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:Text(
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
        return
          MultiSelectBottomSheet(
            listType: MultiSelectListType.CHIP,
            //minChildSize:50,
            maxChildSize:0.4,
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
              child:
              Text(
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
              setState(() {
                _walkingDogs = values;
                if(_walkingDogs.isEmpty)
                {
                  _showScaffold("Собака не выбрана :(");
                }
                else
                {
                  _writeUser.update({
                    'isWalking': (true)
                  })
                      .then((value) => print("Walk status changed"))
                      .catchError((error) => print("Failed to change walk status: $error"));
                  _isWalking = true;
                  _walkingDogs.forEach((element) {
                    _writeUser.collection('dogs').doc(element.id).update(
                        {'isWalking': true});
                  });
                  _writeUser.update({'walkingDogs': _walkingDogs.length});
                  _updatePinOnMap();
                }
              });
            },
          );
      },
    );
  }

  Widget _dogStatus =  _status == true ? SvgPicture.asset('assets/good.svg') : SvgPicture.asset('assets/bad.svg');
  final Widget GoodDogIcon = SvgPicture.asset('assets/good.svg');
  final Widget BadDogIcon = SvgPicture.asset('assets/bad.svg');

  void _onChangeStatusButtonPressed() {

    if (_status == true)
    {
      _dogStatus = BadDogIcon;
      _writeUser.update({'status' : false});
      _status = false;
    }
    else
    {
      _dogStatus = GoodDogIcon;
      _writeUser.update({'status' : true});
      _status = true;
    }
    //дальше обновляем прорисовку марки
    _markers.removeWhere((m)=>m.markerId.value == widget._currentUid); //удаление прорисованной марки
    _markers.removeWhere((m)=>m.markerId.value == widget._currentUid + "/number"); //удаление прорисованной марки
    //и прорисовываем:
    if(mounted) {
      if (_isWalking == true) {
        _markers.add(
            Marker(
                markerId: MarkerId(widget._currentUid),
                icon: _status == true
                    ? _greenLocationIcon
                    : _redLocationIcon,
                position: LatLng(
                    _currentLocation.latitude, _currentLocation.longitude),
                onTap: () {
                  Navigator.of(context).push(SwipeablePageRoute(
                    builder: (BuildContext context) =>
                        DogProfile(widget._currentUid, _walkingDogs.first.id),
                  ));
                })
        );
        _markers.add(
            Marker(
              markerId: MarkerId(widget._currentUid + "/number"),
              icon: _iconNumbers[_walkingDogs.length - 1],
              position: LatLng(
                  _currentLocation.latitude, _currentLocation.longitude),
            )
        );
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
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom()));
    });
  }

  void _onHomeButtonPressed() {
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PersonProfile(uid: widget._currentUid,)));
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
      body: _currentLocation == null
          ? Stack(children: [
        Center(
          child: Text(
            'loading map..',
            style: TextStyle(
                fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
          ),
        ),
        Align(
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
                /*Container(
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
                                  onPressed: _onWalkButtonPressed)),*/
                IconButton(
                    padding: EdgeInsets.zero,
                    icon:
                    Icon(Boxicons.bx_world, color: Color(0xff7e5729)),
                    iconSize: 50),
                //onPressed: _onWalkButtonPressed),
                IconButton(
                    padding: EdgeInsets.zero,
                    icon:
                    Icon(Boxicons.bx_home, color: Color(0xe852a8f7)),
                    iconSize: 50,
                    //padding: ,
                    onPressed: _onHomeButtonPressed),
              ],
            ),
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
          Align(
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
                  /*Container(
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
                                  onPressed: _onWalkButtonPressed)),*/
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
          ),
        ]),
      ),
    );
  }
}
