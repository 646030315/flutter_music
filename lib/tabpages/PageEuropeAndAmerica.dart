import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n_music/main/Constants.dart';
import 'package:permission_handler/permission_handler.dart';

typedef OnMusicPlay = void Function(Map<String, dynamic> song);

class PageEuropeAndAmerica extends StatefulWidget {
  final OnMusicPlay musicPlayListener;

  PageEuropeAndAmerica({this.musicPlayListener});

  @override
  State<StatefulWidget> createState() {
    return PageEuropeAndAmericaState();
  }
}

class PageEuropeAndAmericaState extends State<PageEuropeAndAmerica> {
  static const musicMethodChannel =
      const MethodChannel("com.williscao.n_music.main/music");

  var _songs = <Map<String, dynamic>>[];
  int _permissionState = PERMISSION_NONE;
  int _playingIndex = -1;

  @override
  void initState() {
    super.initState();
    musicMethodChannel.setMethodCallHandler(_onMethodCall);
    _checkPermissions();
  }

  Future<void> _onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'com.williscao.n_music.main/completeSong':
        final String audioPath = call.arguments;
        print("complete song path : $audioPath");
        if (_playingIndex > 0 && _songs[_playingIndex]["path"] == audioPath) {
          _playSong(_playingIndex + 1 % _songs.length);
        }
        break;
      default:
        throw UnimplementedError(
            "${call.method} was invoked but isn't implemented by PlatformViewsService");
    }
    return null;
  }

  /// 权限检测，查看是否需要弹框请求用户权限
  _checkPermissions() async {
    if (_permissionState != PERMISSION_GRANT) {
      PermissionStatus status = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);

      if (status != PermissionStatus.granted) {
        if (status == PermissionStatus.neverAskAgain) {
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

  _playSong(int index) async {
    final path = _songs[index]["path"];
    final result = await musicMethodChannel.invokeListMethod(
        "com.williscao.n_music.main/playSong", path);
    print("_playSong result : ${result[0]}");
    bool bResult = result[0];
    if (bResult) {
      if (widget.musicPlayListener != null) {
        widget.musicPlayListener(_songs[index]);
      }
      setState(() {
        _playingIndex = index;
      });
    }
  }

  _pauseSong(int index) async {
    final path = _songs[index]["path"];
    final result = await musicMethodChannel.invokeListMethod(
        "com.williscao.n_music.main/pauseSong", path);

    print("_playSong result : $result");
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
      onTap: () => _playSong(index),
      child: Container(
        color: Colors.white,
        height: 60,
        child: ListTile(
          selected: _playingIndex == index,
          title: Text(
            _songs[index]["songName"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: _playingIndex == index ? themeColor : Colors.black,
                fontSize: 16),
          ),
          subtitle: Text(
            "${_songs[index]["singerName"]} - ${_songs[index]["album"]}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: _playingIndex == index ? themeColor : Colors.grey,
                fontSize: 12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _getDuration(index),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: _playingIndex == index ? themeColor : Colors.grey),
              ),
            ],
          ),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  "${index + 1}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: _playingIndex == index ? themeColor : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getDuration(int index) {
    if (index >= 0 && index < _songs.length) {
      final int duration = _songs[index]["duration"] ~/ 1000;

      int minute = duration ~/ 60;
      int second = duration % 60;

      return "${minute <= 9 ? "0" : ""}$minute : ${second <= 9 ? "0" : ""}$second";
    }
    return "";
  }
}
