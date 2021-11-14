import 'package:google_maps/services/database.dart';
import 'package:google_maps/views/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/helper/constants.dart';
import 'package:google_maps/const.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;
  bool isLoading = false;

  sendMessage(String userName) {
    if (userName != Constants.myName) {
      List<String> users = [userName, Constants.myName];
      String chatRoomId = getChatRoomId(Constants.myName, userName);

      Map<String, dynamic> chatRoom = {
        "users": users,
        "chatroomId": chatRoomId,
      };

      DatabaseMethods().createChatRoom(chatRoom, chatRoomId);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                    chatRoomId: chatRoomId,
                  )));
    }
  }

  Widget searchList() {
    // return searchResultSnapshot != null ?
    return haveUserSearched
        ? ListView.builder(
            itemCount: searchResultSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return (searchResultSnapshot.docs[index].data()['phoneNumber'] !=
                      Constants.myPhone
                  ? userTile(searchResultSnapshot.docs[index].data()['name'])
                  : Container());
            })
        : Container();
  }

  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseMethods()
          .searchByName(searchEditingController.text)
          .then((snapshot) {
        setState(() {
          print(snapshot.toString());
          searchResultSnapshot = snapshot;
        });
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userTile(String userName) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  child: Text(userName,
                      style: TextStyle(
                          color: defaultBlueSecond,
                          fontSize: 17,
                          fontFamily: defaultFont,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                sendMessage(userName);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: defaultBlueSecond,
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text("Написать",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: defaultFont,
                        fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ));
  }

  getChatRoomId(String a, String b) {
    return ((a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0))
        ? "$b\_$a"
        : "$a\_$b");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              //color: defaultBlueFirst,
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 75),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    //color: defaultBlueFirst,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                                color: defaultBlueSecond,
                                fontSize: 17,
                                fontFamily: defaultFont,
                                fontWeight: FontWeight.w500),
                            controller: searchEditingController,
                            textCapitalization: TextCapitalization.sentences,
                            autocorrect: true,
                            enableSuggestions: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 15.0),
                              filled: true,
                              fillColor: Colors.grey[100],
                              hintText: "поиск...",
                              hintStyle: TextStyle(
                                  color: defaultBlueSecond,
                                  fontSize: 17,
                                  fontFamily: defaultFont,
                                  fontWeight: FontWeight.w500),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: defaultBlueSecond, width: 2.0),
                                gapPadding: 10,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: defaultOrange, width: 2.0),
                                gapPadding: 10,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: defaultBlueSecond, width: 0.0),
                                gapPadding: 10,
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 17,
                        ),
                        GestureDetector(
                          onTap: () {
                            initiateSearch();
                          },
                          child: Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                  color: defaultBlueSecond,
                                  borderRadius: BorderRadius.circular(40)),
                              padding: EdgeInsets.all(12),
                              child: Image.asset(
                                "assets/search_white.png",
                                height: 25,
                                width: 25,
                              )),
                        )
                      ],
                    ),
                  ),
                  searchList()
                  //userList()
                ],
              ),
            ),
    );
  }
}
