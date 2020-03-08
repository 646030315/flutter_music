import 'package:flutter/material.dart';
import 'package:n_music/main/Constants.dart';

class BottomPlayBar extends StatefulWidget {
  final Map<String, dynamic> playingSong;

  BottomPlayBar(
      {this.playingSong = const {
        "songName": "Oxygen",
        "singerName": "王嘉尔",
        "album": "Oxygen"
      }});

  @override
  State<StatefulWidget> createState() {
    return BottomPlayBarState();
  }
}

class BottomPlayBarState extends State<BottomPlayBar> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: bottomBarColor,
        height: 72,
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(AVATAR_URI),
          ),
          title: Text(
            widget.playingSong["songName"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          subtitle: Text(
            "${widget.playingSong["singerName"]} - ${widget.playingSong["album"]}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
