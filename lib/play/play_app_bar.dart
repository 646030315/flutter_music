import 'package:flutter/material.dart';
import 'package:n_music/util/constants.dart';

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
        height: widget.preferredSize.height,
        padding: EdgeInsets.only(top: widget.statusBarHeight),
        child: Stack(alignment: AlignmentDirectional.bottomStart, children: <Widget>[
          Container(
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            GestureDetector(
                onTap: _onBackClick,
                child: Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Image.asset("icon_back.png", width: 15, height: 30))),
            Expanded(
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                  Text(widget.playingSong["songName"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text("${widget.playingSong["singerName"]} - ${widget.playingSong["album"]}",
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 14))
                ]))),
            GestureDetector(
                onTap: _onShareClick,
                child: Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Image.asset("abc_ic_menu_share_mtrl_alpha.png", width: 30, height: 30)))
          ])),
          Container(
              height: 1,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [Color(0x00ffffff), Color(0xffB3B3B3), Color(0x00ffffff)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )))
        ]));
  }

  _onBackClick() {
    Navigator.pop(context, "yep !!!");
  }

  _onShareClick() {}
}
