import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:google_maps/const.dart';
import 'package:google_maps/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/helper/constants.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  ScrollController _controller = new ScrollController();
  double _messageSize;

  Widget chatMessagesList() {
    return
    Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 80),
        child:
      StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Timer(
            Duration(milliseconds: 1),
                () => _controller.jumpTo(_controller.position.maxScrollExtent),
          );
        });
        return snapshot.hasData
            ? ListView.builder(
            controller: _controller,
            itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.docs[index].data()['message'],
                    sendByMe: Constants.myName ==
                        snapshot.data.docs[index].data()['sendBy'],
                  );
            })
            : Container();
      },
    ));
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'sendBy': Constants.myName,
        'message': messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    _controller = ScrollController();
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   Timer(
      Duration(milliseconds: 200),
          () => _controller.jumpTo(_controller.position.maxScrollExtent),
    );
    return Scaffold(
      // TODO: сделать высвечивание имени другого собеседника
      body: Container(
        child: Stack(
          children: [
            chatMessagesList(),
            Container(
              alignment: Alignment.bottomCenter,
              // width: MediaQuery
              //     .of(context)
              //     .size
              //     .width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageEditingController,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      style: TextStyle(
                          color: defaultBlueSecond,
                          fontSize: 17,
                          fontFamily: defaultFont,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18.0),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "Сообщение...",
                        hintStyle: TextStyle(
                            color: defaultBlueSecond,
                            fontSize: 17,
                            fontFamily: defaultFont,
                            fontWeight: FontWeight.w400
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff789fff), width: 2.0),
                          gapPadding: 10,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffee870d), width: 2.0),
                          gapPadding: 10,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: defaultBlueSecond, width: 0.0),
                          gapPadding: 10,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    )),
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                       // _controller.jumpTo(_controller.position.maxScrollExtent);
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: defaultBlueSecond,
                              borderRadius: BorderRadius.circular(40)),
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "assets/send.png",
                            height: 25,
                            width: 25,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        padding:
            EdgeInsets.only(left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
        margin: EdgeInsets.symmetric(vertical: 8),
        width: MediaQuery.of(context).size.width,
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
                color: sendByMe
                    ? Colors.grey[100]
                    : defaultBlueSecond,
              borderRadius: sendByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23))
                  : BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23)),
            ),
            child: Text(message,
                style: sendByMe
                    ? TextStyle(color: defaultBlueSecond,
                    fontSize: 17,
                    fontFamily: defaultFont,
                ) : TextStyle(color: Colors.grey[100],
                  fontSize: 17,
                  fontFamily: defaultFont,
                )))
        );
  }
}
