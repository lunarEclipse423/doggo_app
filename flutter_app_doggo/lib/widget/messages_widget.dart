import 'package:google_maps/api/firebase_api.dart';
import 'package:google_maps/model/message.dart';
import 'package:google_maps/widget/message_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/const.dart';

import '../data.dart';

class MessagesWidget extends StatelessWidget {
  final String idUser;

  const MessagesWidget({
    @required this.idUser,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Message>>(
        stream: FirebaseApi.getMessages(idUser),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return buildText('Что-то пошло не так, попробуйте позднее');
              } else {
                final messages = snapshot.data;

                return messages.isEmpty
                    ? buildText('Напишите первым..')
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          return MessageWidget(
                            message: message,
                            isMe: message.idUser == myId,
                          );
                        },
                      );
              }
          }
        },
      );

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            color: defaultBlueSecond,
            fontFamily: defaultFont,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      );
}
