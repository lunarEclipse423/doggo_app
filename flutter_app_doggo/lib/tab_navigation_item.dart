import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_maps/views/chatrooms.dart';
import 'main.dart';
import 'person_profile.dart';
import 'const.dart';

class TabNavigationItem {
  final Widget page;
  final Icon icon;

  TabNavigationItem({
    @required this.page,
    @required this.icon,
  });
  ChatRoom room;
  static List<TabNavigationItem> get items => [
    TabNavigationItem(
      page: ChatRoom(),
      icon: Icon(PhosphorIcons.chats_circle, size: 50),
    ),
    TabNavigationItem(
      page: Map(FirebaseAuth.instance.currentUser.uid),
      icon: Icon(Boxicons.bx_world, size: 50),
    ),
    TabNavigationItem(
      page: PersonProfile(FirebaseAuth.instance.currentUser.uid),
      icon: Icon(Boxicons.bx_home, size: 50),
    ),
  ];

}