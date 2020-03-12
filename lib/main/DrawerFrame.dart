import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:n_music/util/NLog.dart';
import 'package:n_music/util/Toast.dart';

import 'package:n_music/util/Constants.dart';

class DrawerFrame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DrawerFrameState();
  }
}

class DrawerFrameState extends State<DrawerFrame> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    nLog("DrawerFrameState width: $width");

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: MediaQuery.of(context).padding.top + 161,
          child: Stack(
            children: <Widget>[
              ConstrainedBox(
                child: Image.asset(
                  AVATAR_URI,
                  fit: BoxFit.cover,
                ),
                constraints: BoxConstraints.expand(),
              ),
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: BLUR_SIGMA_X, sigmaY: BLUR_SIGMA_Y),
                  child: Container(
                    color: Colors.white.withOpacity(0),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(32))),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(AVATAR_URI),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, bottom: 8),
                alignment: Alignment.bottomLeft,
                child: Text("williscao", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _onHomeTap,
          child: ListTile(leading: Icon(Icons.home), title: Text("Home")),
        ),
        InkWell(
          onTap: _onMessageTap,
          child: ListTile(leading: Icon(Icons.message), title: Text("Message")),
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
    // https://qzonestyle.gtimg.cn/aoi/sola/20200225100716_PCSqBR2pS7.png
    Toast.show(context, "_onHomeTap tap");
  }

  _onMessageTap() async {
    Toast.show(context, "_onMessageTap tap");
  }

  _onPhotoTap() async {
    Toast.show(context, "_onPhotoTap tap");
  }
}
