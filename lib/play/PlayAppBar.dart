import 'package:flutter/material.dart';
import 'package:n_music/main/Constants.dart';

class PlayAppBar extends StatefulWidget implements PreferredSizeWidget {
  final statusBarHeight;
  final playingSong;

  PlayAppBar({this.statusBarHeight, this.playingSong});

  @override
  State<StatefulWidget> createState() {
    return PlayAppBarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(statusBarHeight + TITLE_BAR_HEIGHT);
}

class PlayAppBarState extends State<PlayAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: widget.statusBarHeight),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: _onBackClick,
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Image.asset("icon_back.png", width: 15, height: 30),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.playingSong["songName"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          "${widget.playingSong["singerName"]} - ${widget.playingSong["album"]}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _onShareClick,
                  child: Container(
                    width: 40,
                    margin: EdgeInsets.only(right: 10),
                    child: Image.asset(
                      "abc_ic_menu_share_mtrl_alpha.png",
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  _onBackClick() {
    Navigator.pop(context, "yep !!!");
  }

  _onShareClick() {}
}
