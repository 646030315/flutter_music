import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n_music/main/Constants.dart';
import 'package:permission_handler/permission_handler.dart';

class PageEuropeAndAmerica extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageEuropeAndAmericaState();
  }
}

class PageEuropeAndAmericaState extends State<PageEuropeAndAmerica> {
  static const musicMethodChannel =
      const MethodChannel("com.williscao.n_music.main/music");

  var _songs = <Map<String, dynamic>>[
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
    {"songName": "爱的魔力转圈圈", "singerName": "williscao"},
  ];
  int _permissionState = PERMISSION_NONE;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// 权限检测，查看是否需要弹框请求用户权限
  _checkPermissions() async {
    if (_permissionState != PERMISSION_GRANT) {
      PermissionStatus status = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);

      if (status != PermissionStatus.granted) {
        if (status == PermissionStatus.disabled ||
            status == PermissionStatus.neverAskAgain) {
          // 如果功能无法使用或者用户设置不在弹窗，这里不做任何事情，不弹框，不请求
          _permissionState = PERMISSION_DENY;
        } else {
          _requestPermission();
        }
      } else {
        _getSongList();
      }
    } else {
      _getSongList();
    }
  }

  /// 动态请求权限，目前需要的权限是存储权限
  _requestPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    bool granted = true;
    permissions.forEach((key, value) {
      if (value != PermissionStatus.granted) {
        granted = false;
      }
    });
    _permissionState = granted ? PERMISSION_GRANT : PERMISSION_DENY;

    if (_permissionState == PERMISSION_GRANT) {
      _getSongList();
    }
  }

  _getSongList() async {
    final songs = await musicMethodChannel
        .invokeListMethod("com.williscao.n_music.main/getSongList");

    print(songs);
    setState(() {
      _songs = songs.map((element) {
        Map<String, dynamic> map = jsonDecode(element);
        return map;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Divider(
            height: 1,
            color: Color(0xFFFAFAFA),
          ),
          Container(
            margin: EdgeInsets.only(top: 1),
            child: ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  return _getItemView(context, index);
                }),
          ),
        ],
      ),
    );
  }

  Widget _getItemView(BuildContext context, int index) {
    return GestureDetector(
      onTap: _requestPermission,
      child: Container(
        color: Colors.white,
        height: 80,
        alignment: Alignment.center,
        child: ListTile(
          title: Text(
            _songs[index]["songName"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          subtitle: Text(
            "${_songs[index]["singerName"]} - ${_songs[index]["album"]}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: Icon(Icons.add),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(AVATAR_URI),
          ),
        ),
      ),
    );
  }
}
