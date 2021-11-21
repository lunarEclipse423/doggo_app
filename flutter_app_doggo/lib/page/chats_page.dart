import 'package:google_maps/api/firebase_api.dart';
import 'package:google_maps/model/user.dart';
import 'package:google_maps/widget/chat_body_widget.dart';
import 'package:google_maps/widget/chat_header_widget.dart';
import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  final String currentUid;

  const ChatsPage({
    @required this.currentUid,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: StreamBuilder<List<User>>(
        stream: FirebaseApi.getUsers(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                print(snapshot.error);
                return buildText('Что-то пошло не так, попробуйте позднее');
              } else {
                final users = snapshot.data;
                // TODO: сделать отображение всех пользователей из БД кроме текущего
                //var users = snapshot.data;
                //users.removeWhere((user) => user.idUser == currentUid);

                if (users.isEmpty) {
                  return buildText('Ни одного пользователя не найдено');
                } else {
                  return Column(
                    children: [
                      // Верхний виджет с заголовком
                      ChatHeaderWidget(users: users),
                      // Виджет скроллинга чатов
                      ChatBodyWidget(users: users)
                    ],
                  );
                }
              }
          }
        },
      ),
    ),
  );

  Widget buildText(String text) => Center(
    child: Text(
      text,
      style: TextStyle(fontSize: 24, color: Colors.white),
    ),
  );
}
