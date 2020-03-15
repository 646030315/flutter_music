import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:n_music/customwidget/progress_bar.dart';
import 'package:n_music/customwidget/adjustable_bottom_sheet.dart';
import 'package:n_music/play/page_play_bottom_sheet.dart';
import 'package:n_music/util/constants.dart';
import 'package:n_music/controller/music_playper_controller.dart';
import 'package:n_music/util/n_log.dart';
import 'package:n_music/play/play_app_bar.dart';
import 'dart:math' as math;

import 'package:n_music/util/time_utils.dart';

class PagePlay extends StatefulWidget {
  final MusicPlayerController musicPlayerController;

  PagePlay({this.musicPlayerController});

  @override
  State<StatefulWidget> createState() {
    return PagePlayState();
  }
}

class PagePlayState extends State<PagePlay> with SingleTickerProviderStateMixin {
  int _progress = 0;
  int _progressPercent = 0;
  int _bufferedPercent = 0;
  int _duration = 0;

  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(duration: const Duration(milliseconds: 60000), vsync: this);
    controller.addListener(_diskRotateListener);
    controller.repeat();

    nLog("PagePlay initState");

    widget.musicPlayerController?.addOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
    widget.musicPlayerController?.addOnMusicPlayingErrorListener(_onMusicPlayingError);
    widget.musicPlayerController?.addOnMusicProgressListener(_onMusicProgressUpdate);
  }

  void _diskRotateListener() {
    setState(() {});
  }

  @override
  void dispose() {
    controller.stop();
    controller.removeListener(_diskRotateListener);
    controller.dispose();

    super.dispose();
    nLog("animator controller do dispose");

    widget.musicPlayerController?.removeOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
    widget.musicPlayerController?.removeOnMusicPlayingErrorListener(_onMusicPlayingError);
    widget.musicPlayerController?.removeOnMusicProgressListener(_onMusicProgressUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PlayAppBar(statusBarHeight: statusBarHeight, playingSong: widget.musicPlayerController.curSong()),
        body: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[_getBigImageBg(), _getBody(), _getBottomView()]));
  }

  _getBigImageBg() {
    return ConstrainedBox(child: Image.asset("fm_run_bg.jpg", fit: BoxFit.cover), constraints: BoxConstraints.expand());
  }

  _getBottomView() {
    return Container(
      height: 110,
      child: Column(
        children: <Widget>[_getSeekBar(), _getBottomController()],
      ),
    );
  }

  _getSeekBar() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        alignment: Alignment.center,
        height: 20,
        child: Row(children: <Widget>[
          Container(child: Text(formatSongTimeLength(_progress), style: TextStyle(color: Colors.white, fontSize: 12))),
          Expanded(
              child: ProgressBar(
                  onSeekToListener: _onMusicSeek,
                  needDrag: true,
                  progressPercent: _progressPercent,
                  bufferedPercent: _bufferedPercent)),
          Container(child: Text(formatSongTimeLength(_duration), style: TextStyle(color: Colors.white, fontSize: 12)))
        ]));
  }

  _onMusicSeek(double percent) {
    widget.musicPlayerController?.seekTo(percent);
  }

  _getBody() {
    double diskSize = (window.physicalSize.width * 2) / (3 * window.devicePixelRatio);
    return Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(alignment: Alignment.topCenter, children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + TITLE_BAR_HEIGHT + 50),
              child: Image.asset("play_disc.png", width: diskSize, height: diskSize)),
          Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + TITLE_BAR_HEIGHT + 50 + (diskSize / 6)),
              width: diskSize * 2 / 3,
              height: diskSize * 2 / 3,
              child: Transform(
                  transform: Matrix4.rotationZ((controller.value) * math.pi * 2.0),
                  alignment: Alignment.center,
                  child: CircleAvatar(radius: diskSize / 3, backgroundImage: AssetImage(AVATAR_URI))))
        ]));
  }

  _getBottomController() {
    final double bottomPadding = 20;
    final double containerHeight = 70;
    return Container(
        height: bottomPadding + containerHeight,
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          Expanded(
              child: GestureDetector(
                  onTap: _onSwitchLoopMode,
                  child: Container(
                      height: containerHeight,
                      alignment: Alignment.center,
                      child: Text(widget.musicPlayerController.getLoopModeName(),
                          style: TextStyle(color: Colors.white, fontSize: 12))))),
          Expanded(
              child: GestureDetector(
                  onTap: _onPreSongClick,
                  child: Container(
                      height: containerHeight, alignment: Alignment.center, child: Image.asset("play_btn_prev.png")))),
          Expanded(
              child: GestureDetector(
                  onTap: _onPauseResumeClick,
                  child: Container(
                      height: containerHeight,
                      alignment: Alignment.center,
                      child: Image.asset(
                          !widget.musicPlayerController.isPlaying ? "play_btn_play.png" : "play_btn_pause.png")))),
          Expanded(
              child: GestureDetector(
                  onTap: _onNextClick,
                  child: Container(
                      height: containerHeight,
                      alignment: Alignment.center,
                      child: Image.asset("play_btn_next.png", color: Colors.white)))),
          Expanded(
              child: GestureDetector(
                  onTap: _songListClick,
                  child: Container(
                      height: containerHeight,
                      alignment: Alignment.center,
                      child: Image.asset("play_icn_src_prs.png", width: 55, height: 55))))
        ]));
  }

  void _onSwitchLoopMode() {
    widget.musicPlayerController.switchLoopMode();
    setState(() {});
  }

  void _onPreSongClick() {
    widget.musicPlayerController.preSong();
  }

  void _onPauseResumeClick() {
    widget.musicPlayerController.pauseOrResume();
  }

  void _onNextClick() {
    widget.musicPlayerController.nextSong();
  }

  void _songListClick() {
    showAdjustableModalBottomSheet(context: context, builder: (_) => PagePlayBottomSheet(widget.musicPlayerController));
  }

  void _onMusicPlayingStateChange(bool isPlaying, int index, Map<String, dynamic> song) {
    nLog("_onMusicPlayingStateChange isPlaying : $isPlaying , song : $song");
    if (isPlaying) {
      controller.repeat();
    } else {
      controller.stop(canceled: false);
    }
    setState(() {});
  }

  void _onMusicPlayingError(int index, Map<String, dynamic> song) {
    nLog("_onMusicPlayingError index : $index , song : $song");
    if (widget.musicPlayerController.curSong()["path"] == song["path"]) {
      widget.musicPlayerController.curSong()["audio_broken"] = true;
      widget.musicPlayerController?.nextSong();
    }
  }

  void _onMusicProgressUpdate(int progress, int buffered, int duration) {
    setState(() {
      _progressPercent = progress * 100 ~/ duration;
      _bufferedPercent = buffered * 100 ~/ duration;

      _progress = progress ~/ 1000;
      _duration = duration ~/ 1000;
    });
  }
}
