import 'package:flutter/material.dart';
import 'package:n_music/main/Constants.dart';
import 'package:n_music/main/MusicPlayerController.dart';
import 'package:permission_handler/permission_handler.dart';

typedef OnMusicPlay = void Function(Map<String, dynamic> song);

class PageEuropeAndAmerica extends StatefulWidget {
  final OnMusicPlay musicPlayListener;
  final MusicPlayerController musicPlayerController;

  PageEuropeAndAmerica({this.musicPlayListener, this.musicPlayerController});

  @override
  State<StatefulWidget> createState() {
    return PageEuropeAndAmericaState();
  }
}

class PageEuropeAndAmericaState extends State<PageEuropeAndAmerica> {
  var _songs = <Map<String, dynamic>>[];
  int _permissionState = PERMISSION_NONE;
  int _playingIndex = -1;

  @override
  void initState() {
    super.initState();
    _checkPermissions();

    print("PageEuropeAndAmericaState initState");
    widget.musicPlayerController
        ?.addOnMusicLoadCompleteListener(_onMusicLoadComplete);
    widget.musicPlayerController
        ?.addOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
  }

  @override
  void dispose() {
    super.dispose();

    widget.musicPlayerController
        ?.removeOnMusicLoadCompleteListener(_onMusicLoadComplete);
    widget.musicPlayerController
        ?.removeOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
  }

  void _onMusicLoadComplete(List<Map<String, dynamic>> songList) {
    setState(() {
      _songs = songList;
    });
  }

  void _onMusicPlayingStateChange(
      bool isPlaying, int index, Map<String, dynamic> song) {
    print("_onMusicPlayingStateChange isPlaying : $isPlaying , song : $song");

    setState(() {
      _playingIndex = index;
    });
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
        widget.musicPlayerController?.getSongList();
      }
    } else {
      widget.musicPlayerController?.getSongList();
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
      widget.musicPlayerController?.getSongList();
    }
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
      onTap: () => _onItemClick(index),
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

  _onItemClick(int position) {
    _playingIndex = position;
    widget.musicPlayerController?.playSong(position);
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
