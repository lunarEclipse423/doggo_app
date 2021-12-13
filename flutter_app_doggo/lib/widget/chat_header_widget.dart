import 'package:google_maps/model/user.dart';

import 'package:google_maps/page/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/const.dart';

class ChatHeaderWidget extends StatelessWidget {
  final List<User> users;

  const ChatHeaderWidget({
    @required this.users,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                //width: MediaQuery.of(context).size.width * 0.75,
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
            SizedBox(height: 12),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  if (index == 0) {
                    return Container(
                      margin: EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.search),
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatPage(user: users[index]),
                          ));
                        },
                        child: CircleAvatar(
                          radius: 24,
                          // TODO: получение фотографии человека с БД
                          backgroundImage: NetworkImage(
                              "https://cdn.imgbin.com/22/6/6/imgbin-google-account-google-search-customer-service-google-logo-login-button-mn3etzG3BCnc2fL70jnu2nedu.jpg" /*user.urlAvatar*/),
                        ),
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      );
}
