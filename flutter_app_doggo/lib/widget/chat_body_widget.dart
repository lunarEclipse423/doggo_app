import 'package:google_maps/model/user.dart';

import 'package:google_maps/page/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/const.dart';

class ChatBodyWidget extends StatelessWidget {
  final List<User> users;

  const ChatBodyWidget({
    @required this.users,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: buildChats(),
        ),
      );

  Widget buildChats() => ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final user = users[index];

            return Container(
              height: 75,
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatPage(user: user),
                  ));
                },
                leading: CircleAvatar(
                  radius: 25,
                  // TODO: получение фотографии человека с БД
                  backgroundImage: NetworkImage(
                      "https://cdn.imgbin.com/22/6/6/imgbin-google-account-google-search-customer-service-google-logo-login-button-mn3etzG3BCnc2fL70jnu2nedu.jpg" /*user.urlAvatar*/),
                ),
                title: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 18,
                    color: defaultBlueSecond,
                    fontFamily: defaultFont,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.26,
                  ),
                ),
              ),
            );
        },
        itemCount: users.length,
      );
}
