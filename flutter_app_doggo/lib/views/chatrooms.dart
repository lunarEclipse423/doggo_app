import 'package:google_maps/services/database.dart';
import 'package:google_maps/views/search.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/helper/constants.dart';
import 'package:google_maps/helper/helper_functions.dart';
import 'package:google_maps/views/chat.dart';
import 'package:google_maps/const.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatRooms;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                    userName: snapshot.data.docs[index]
                        .data()['chatroomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myName, ""),
                    chatRoomId: snapshot.data.docs[index].data()['chatroomId'],
                  );
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myPhone = await HelperFunctions.getUserPhoneSharedPreference();
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${Constants.myName}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                        child: Text(
                          'Чаты',
                          style: TextStyle(
                            fontSize: 28,
                            color: defaultBlueSecond,
                            fontFamily: defaultFont,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.26,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        width: 360,
                        height: 43,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Search()));
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(defaultOrange),
                                foregroundColor: MaterialStateProperty.all(
                                  defaultOrange,
                                ),
                                overlayColor:
                                    MaterialStateProperty.all(defaultOrange),
                                shadowColor:
                                    MaterialStateProperty.all(defaultOrange),
                                side: MaterialStateProperty.all(BorderSide(
                                    width: 155,
                                    style: BorderStyle.none,
                                    color: defaultOrange)),
                                enableFeedback: false,
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                        side:
                                            BorderSide(color: defaultOrange)))),
                            child: Text(
                              "Найти собеседника",
                              style: TextStyle(
                                color: Color(0xfffbfbfb),
                                fontSize: 18,
                                fontFamily: defaultFont,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                      ),
                      Container(
                        child: chatRoomsList(),
                      ),
                    ]))));
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({this.userName, @required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      chatRoomId: chatRoomId,
                    )));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: defaultBlueSecond,
                  borderRadius: BorderRadius.circular(30)),
              child: Text(userName.substring(0, 1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: defaultFont,
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              width: 12,
            ),
            Text(userName,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: defaultBlueSecond,
                    fontSize: 16,
                    fontFamily: defaultFont,
                    fontWeight: FontWeight.w600))
          ],
        ),
      ),
    );
  }
}
