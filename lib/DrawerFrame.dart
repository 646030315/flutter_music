import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n_music/Toast.dart';

class DrawerFrame extends StatefulWidget {

  DrawerFrame({Key key, this.sGlobalKey}) : super(key: key);
  final GlobalKey<ScaffoldState> sGlobalKey;
  @override
  State<StatefulWidget> createState() {
    return DrawerFrameState();
  }
}

class DrawerFrameState extends State<DrawerFrame> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.grey
          ),
          child: Center(
            child: Text("Drawer header")
          ),
        ),
        InkWell(
          onTap: _onHomeTap,
          child: ListTile(
            leading: Icon(Icons.home),
            title: Text("Home")
          ),
        ),
        InkWell(
          onTap: _onMessageTap,
          child: ListTile(
            leading: Icon(Icons.message),
            title: Text("Message")
          ),
        ),
        InkWell(
          onTap: _onPhotoTap,
          child: ListTile(
            leading: Icon(Icons.photo),
            title: Text("Photo"),
          ),
        ),
      ],
    );
  }

  _onHomeTap() {
    Toast.show(context, "onHomeTap");
  }

  _onMessageTap() {
    Toast.show(context, "onMessageTap");
  }

  _onPhotoTap() {
    Toast.show(context, "onPhotoTap");
  }
}
