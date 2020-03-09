import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:n_music/main/Constants.dart';

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

  @override
  void initState() {
    super.initState();

    print("BottomPlayBarState initState");

    widget.musicPlayerController
        ?.addOnMusicPlayingChangeListener(_onMusicPlayingStateChange);

    widget.musicPlayerController
        ?.addOnMusicProgressListener(_onMusicProgressUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    print("BottomPlayBarState dispose");
    widget.musicPlayerController
        ?.removeOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
    widget.musicPlayerController
        ?.removeOnMusicProgressListener(_onMusicProgressUpdate);
  }

  void _onMusicPlayingStateChange(bool isPlaying, int index, Map<String, dynamic> song) {
    setState(() {
      _isPlaying = isPlaying;
    });
  }

  void _onMusicProgressUpdate(int progress) {
    setState(() {
      _progressWidth = (window.physicalSize.width * progress) /
          (100 * window.devicePixelRatio);

      print(
          "_onMusicProgressUpdate windowWidth : ${window.physicalSize.width} , progress : $progress, progressWidth: $_progressWidth, devicePixelRatio : ${window.devicePixelRatio}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                        width: 30,
                        child: Image.asset("playbar_btn_playlist.png"),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onPauseResumeClick,
                      child: Container(
                        width: 30,
                        child: Image.asset(!_isPlaying
                            ? "playbar_btn_play.png"
                            : "playbar_btn_pause.png"),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onNextClick,
                      child: Container(
                        width: 30,
                        child: Image.asset("playbar_btn_next.png"),
                      ),
                    ),
                  ],
                ),
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

  /// 展示当前的播放列表
  _onSongListClick() {

  }

  _onPauseResumeClick() {
    widget.musicPlayerController?.pauseOrResume();
  }

  _onNextClick() {
    widget.musicPlayerController?.nextSong();
  }
}
