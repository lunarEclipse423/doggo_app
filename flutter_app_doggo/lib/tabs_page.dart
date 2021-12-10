import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/const.dart';
import 'tab_navigation_item.dart';
import 'package:firebase_storage/firebase_storage.dart';


bool isEntry = true;

class TabsPage extends StatefulWidget {
  int _currentIndex = 1;
  TabsPage({int index}):_currentIndex = index;
  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  //int _currentIndex = 1;
  @override
  void initState() {

    if(isEntry == true)
      {
        _addUsedIdDB();
      }
    // TODO: implement initState
    super.initState();

  }

  _setUserData() async
  {
    writeUser = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid);
   writeUser.update({
      'isWalking': false,
      'status' : true});
    final CollectionReference writeDogs = writeUser.collection('dogs');
    final QuerySnapshot dogs = await writeUser.collection('dogs').get();
    final List<DocumentSnapshot> docDogs = dogs.docs;
    docDogs.forEach((dog) {
      writeDogs.doc(dog.id).update({'isWalking' : false});
    });

    isEntry = false;
  }

  _addUsedIdDB() async {
    writeUser = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid);

    if (register == true) {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('users/' + FirebaseAuth.instance.currentUser.uid + '/profile');

      print('Reference Created');
      UploadTask uploadTask = storageReference.putFile(PersonImage);
      print('File Uploaded');

      writeUser.set({
        'name': myName,
        'phoneNumber': phoneNumber,
        'location' : GeoPoint(0.0, 0.0),
        'isWalking' : false,
        'status' : true,
        'walkingDogs' : 0,
        'idUser' : FirebaseAuth.instance.currentUser.uid,
        'personImageURL' : ' '
      }, SetOptions(merge: false));

    }
    else{
      writeUser.update({
        'isWalking': false,
        'status' : true});
      final CollectionReference writeDogs = writeUser.collection('dogs');
      final QuerySnapshot dogs = await writeUser.collection('dogs').get();
      final List<DocumentSnapshot> docDogs = dogs.docs;
      docDogs.forEach((dog) {
        writeDogs.doc(dog.id).update({'isWalking' : false});
      });
      //Navigator.pushNamedAndRemoveUntil(context, '/map/${FirebaseAuth.instance.currentUser.uid}', (route) => false);
    }
    isEntry = false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: widget._currentIndex,
        children: [
          for (final tabItem in TabNavigationItem.items) tabItem.page,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget._currentIndex,
          unselectedItemColor: Color(0xe852a8f7),
        selectedItemColor: Color(0xffee870d),
        backgroundColor: Color(0xe5ffffff),
        onTap: (int index) => setState(() => widget._currentIndex = index),
        items: [
          for (final tabItem in TabNavigationItem.items)
            BottomNavigationBarItem(
              icon: tabItem.icon,
              label: '',
            )
        ],
      ),
    );
  }
}

