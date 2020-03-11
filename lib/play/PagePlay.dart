import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:n_music/main/Constants.dart';
import 'package:n_music/main/MusicPlayerController.dart';
import 'package:n_music/main/NLog.dart';
import 'package:n_music/play/PlayAppBar.dart';

class PagePlay extends StatefulWidget {
  final MusicPlayerController musicPlayerController;

  PagePlay({this.musicPlayerController});

  @override
  State<StatefulWidget> createState() {
    return PagePlayState();
  }
}

class PagePlayState extends State<PagePlay> implements TickerProvider{
  Map<String, dynamic> _playingSong;
  double _progressWidth = 0;
  double _bufferedWidth = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _playingSong = widget.musicPlayerController.curSong();
    nLog("PagePlay initState");

    widget.musicPlayerController
        ?.addOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
    widget.musicPlayerController
        ?.addOnMusicPlayingErrorListener(_onMusicPlayingError);
    widget.musicPlayerController
        ?.addOnMusicProgressListener(_onMusicProgressUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    widget.musicPlayerController
        ?.removeOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
    widget.musicPlayerController
        ?.removeOnMusicPlayingErrorListener(_onMusicPlayingError);
    widget.musicPlayerController
        ?.removeOnMusicProgressListener(_onMusicProgressUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: PlayAppBar(
          statusBarHeight: statusBarHeight, playingSong: _playingSong),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          _getBigImageBg(),
          _getBody(),
          _getBottomController(),
        ],
      ),
    );
  }

  _getBigImageBg() {
    nLog("_getBigImageBg");

    return ConstrainedBox(
      child: Image.asset(
        "fm_run_bg.jpg",
        fit: BoxFit.cover,
      ),
      constraints: BoxConstraints.expand(),
    );
  }

  _getBody() {
    AnimationController ac = AnimationController(duration: const Duration(microseconds: 30 * 1000), vsync: this);
    double diskSize =
        (window.physicalSize.width * 2) / (3 * window.devicePixelRatio);
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
                top:
                    MediaQuery.of(context).padding.top + TITLE_BAR_HEIGHT + 50),
            child: Image.asset(
              "play_disc.png",
              width: diskSize,
              height: diskSize,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top +
                    TITLE_BAR_HEIGHT +
                    50 +
                    (diskSize / 6)),
            child: CircleAvatar(
              radius: diskSize / 3,
              backgroundImage: AssetImage(AVATAR_URI),
            ),
          ),
          RotationTransition(
            turns: ac,
            alignment: Alignment.center,
            child: Container(
              width: diskSize * 2 / 3,
              height: diskSize * 2 / 3,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top +
                      TITLE_BAR_HEIGHT +
                      50 +
                      (diskSize / 6)),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: BLUR_SIGMA_X, sigmaY: BLUR_SIGMA_Y),
                  child: Container(
                    color: Colors.white.withOpacity(0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getBottomController() {
    return Container();
  }

  void _onMusicPlayingStateChange(
      bool isPlaying, int index, Map<String, dynamic> song) {
    nLog("_onMusicPlayingStateChange isPlaying : $isPlaying , song : $song");

    setState(() {
      _playingSong = song;
      _isPlaying = isPlaying;
    });
  }

  void _onMusicPlayingError(int index, Map<String, dynamic> song) {
    nLog("_onMusicPlayingError index : $index , song : $song");
    if (widget.musicPlayerController.curSong()["path"] == song["path"]) {
      widget.musicPlayerController.curSong()["audio_broken"] = true;
      widget.musicPlayerController?.nextSong();
    }
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
  Ticker createTicker(onTick) {
    return Ticker(onTick);
  }
}
