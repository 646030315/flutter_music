import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:n_music/controller/music_playper_controller.dart';
import 'package:n_music/util/constants.dart';
import 'package:n_music/util/n_log.dart';
import 'package:n_music/util/time_utils.dart';
import 'dart:math' as math;

class PagePlayBottomSheet extends StatefulWidget {
  final MusicPlayerController musicPlayerController;

  PagePlayBottomSheet(this.musicPlayerController);

  @override
  State<StatefulWidget> createState() {
    return PagePlayBottomSheetState();
  }
}

class PagePlayBottomSheetState extends State<PagePlayBottomSheet> {
  int _playingIndex = -1;
  final ScrollController _sc = ScrollController();

  final double itemHeight = 60;
  bool _hasShowFirst = false;

  @override
  void initState() {
    super.initState();

    nLog("PagePlayBottomSheetState initState");
    widget.musicPlayerController?.addOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
    _playingIndex = widget.musicPlayerController.playingIndex;
  }

  @override
  void dispose() {
    super.dispose();
    widget.musicPlayerController?.removeOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
  }

  void _onMusicPlayingStateChange(bool isPlaying, int index, Map<String, dynamic> song) {
    nLog("PagePlayBottomSheetState _onMusicPlayingStateChange isPlaying : $isPlaying , song : $song");

    setState(() {
      _playingIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
    return Container(
        alignment: Alignment.center,
        child: ListView.builder(
            controller: _sc,
            itemCount: widget.musicPlayerController?.songs?.length,
            itemBuilder: (context, index) {
              return _getItemView(context, index);
            }));
  }

  _afterBuild(Duration duration) {
    nLog(
        "PagePlayBottomSheetState _afterBuild height : ${context.size.height}, windowHeight : ${window.physicalSize.height}");

    if (!_hasShowFirst) {
      _hasShowFirst = true;
      _onShowFirst();
    }
  }

  /// 界面第一次绘制完成回调
  _onShowFirst() {
    _scrollToPlayingSong();
  }

  /// 滑动到正在播放的音乐的地方
  _scrollToPlayingSong() {
    final double sheetHeight = context.size.height;

    double scrollDistance = math.min(widget.musicPlayerController.songs.length * itemHeight - sheetHeight,
        math.max(0, _playingIndex * itemHeight - (sheetHeight - itemHeight) / 2.0));

    _sc.animateTo(scrollDistance, duration: Duration(milliseconds: 200), curve: Curves.fastLinearToSlowEaseIn);
  }

  Widget _getItemView(BuildContext context, int index) {
    final _songs = widget.musicPlayerController.songs;
    return GestureDetector(
        onTap: () => _onItemClick(index),
        child: Container(
            color: Colors.white,
            height: itemHeight,
            child: ListTile(
                title: Text(_songs[index]["songName"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _getItemTitleTextColor(index), fontSize: 16)),
                subtitle: Text("${_songs[index]["singerName"]} - ${_songs[index]["album"]}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _getItemSubTitleTextColor(index), fontSize: 12)),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text(_getDuration(index),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: _playingIndex == index ? themeColor : Colors.grey))
                ]),
                leading: Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text("${index + 1}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: _playingIndex == index ? themeColor : Colors.grey))))));
  }

  /// 获取标题文字颜色
  _getItemTitleTextColor(int index) {
    return _playingIndex == index ? themeColor : Colors.black;
  }

  /// 获取子标题文字颜色
  _getItemSubTitleTextColor(int index) {
    return _playingIndex == index ? themeColor : Colors.grey;
  }

  /// item点击监听
  _onItemClick(int position) {
    _playingIndex = position;
    widget.musicPlayerController?.playSong(position);
  }

  /// 音频时长
  _getDuration(int index) {
    if (index >= 0 && index < widget.musicPlayerController?.songs?.length) {
      final int duration = widget.musicPlayerController?.songs[index]["duration"] ~/ 1000;
      return formatSongTimeLength(duration);
    }
    return "";
  }
}
