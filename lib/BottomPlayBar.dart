import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:n_music/Toast.dart';
import 'package:n_music/main/Constants.dart';
import 'package:n_music/main/NLog.dart';
import 'package:n_music/play/PagePlay.dart';

import 'main/MusicPlayerController.dart';

class BottomPlayBar extends StatefulWidget {
  final Map<String, dynamic> playingSong;
  final MusicPlayerController musicPlayerController;

  BottomPlayBar({this.playingSong, this.musicPlayerController});

  @override
  State<StatefulWidget> createState() {
    return BottomPlayBarState();
  }
}

class BottomPlayBarState extends State<BottomPlayBar> {
  bool _isPlaying = false;
  double _progressWidth = 0;
  double _bufferedWidth = 0;

  @override
  void initState() {
    super.initState();

    nLog("BottomPlayBarState initState");

    widget.musicPlayerController
        ?.addOnMusicPlayingChangeListener(_onMusicPlayingStateChange);

    widget.musicPlayerController
        ?.addOnMusicProgressListener(_onMusicProgressUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    nLog("BottomPlayBarState dispose");
    widget.musicPlayerController
        ?.removeOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
    widget.musicPlayerController
        ?.removeOnMusicProgressListener(_onMusicProgressUpdate);
  }

  void _onMusicPlayingStateChange(
      bool isPlaying, int index, Map<String, dynamic> song) {
    setState(() {
      _isPlaying = isPlaying;
    });
  }

  void _onMusicProgressUpdate(int progressPercent, int bufferedPercent) {
    setState(() {
      _progressWidth = (window.physicalSize.width * progressPercent) /
          (100 * window.devicePixelRatio);

      _bufferedWidth = (window.physicalSize.width * bufferedPercent) /
          (100 * window.devicePixelRatio);

      nLog(
          "_onMusicProgressUpdate windowWidth : ${window.physicalSize.width} , progress : $progressPercent, progressWidth: $_progressWidth, _bufferedWidth: $_bufferedWidth, devicePixelRatio : ${window.devicePixelRatio}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onJumpToPlayPage,
      child: Container(
          color: bottomBarColor,
          height: BOTTOM_BAR_HEIGHT,
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(AVATAR_URI),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.playingSong["songName"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            Text(
                              "${widget.playingSong["singerName"]} - ${widget.playingSong["album"]}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onSongListClick,
                      child: Container(
                        width: 40,
                        child: Image.asset("playbar_btn_playlist.png"),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onPauseResumeClick,
                      child: Container(
                        width: 40,
                        child: Image.asset(!_isPlaying
                            ? "playbar_btn_play.png"
                            : "playbar_btn_pause.png"),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onNextClick,
                      child: Container(
                        width: 40,
                        child: Image.asset("playbar_btn_next.png"),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 2,
                width: _bufferedWidth,
                color: Colors.grey,
              ),
              Container(
                height: 2,
                width: _progressWidth,
                color: themeColor,
              ),
            ],
          )),
    );
  }

  _onJumpToPlayPage() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PagePlay(
            musicPlayerController: widget.musicPlayerController,
          ),
        ));

    nLog("result from page PagePlay : $result");
  }

  /// 展示当前的播放列表
  _onSongListClick() {
    Toast.show(context, widget.musicPlayerController?.switchLoopMode());
  }

  /// 暂停或者恢复播放，根据当前状态
  _onPauseResumeClick() {
    widget.musicPlayerController?.pauseOrResume();
  }

  /// 下一首
  _onNextClick() {
    widget.musicPlayerController?.nextSong();
  }
}
