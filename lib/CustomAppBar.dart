import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n_music/main/Constants.dart';
import 'package:n_music/main/PressStateButton.dart';

class CustomAppBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CustomAppBarState();
  }
}

class CustomAppBarState extends State<CustomAppBar> {
  void _handleDrawerOpen() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
      ),
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + TITLE_BAR_HEIGHT,
      child: Stack(
        children: <Widget>[
          InkWell(
            onTap: _handleDrawerOpen,
            child: Container(
              width: 40,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 5, right: 5),
              margin: const EdgeInsets.only(left: 11),
              child: Image.asset("ic_menu.png",
                  width: 30, height: 30, alignment: Alignment.center),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PressStateButton(
                  "actionbar_discover_prs.png",
                  "actionbar_discover_selected.png",
                  width: 60,
                  height: 60,
                  onTap: _onTap,
                ),
                PressStateButton(
                  "actionbar_friends_prs.png",
                  "actionbar_friends_selected.png",
                  width: 60,
                  height: 60,
                  onTap: _onTap,
                ),
                PressStateButton(
                  "actionbar_music_prs.png",
                  "actionbar_music_selected.png",
                  width: 60,
                  height: 60,
                  onTap: _onTap,
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset("icon_search.png",
                width: 25, height: 25, alignment: Alignment.center),
          ),
        ],
      ),
    );
  }

  _onTap() {}
}
