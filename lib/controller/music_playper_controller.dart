import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:n_music/loop/loop_mode.dart';
import 'package:n_music/util/n_log.dart';

typedef OnMusicLoadCompleteListener = void Function(
    List<Map<String, dynamic>> songList);

typedef OnMusicProgressListener = void Function(
    int progress, int buffered, int duration);

typedef OnMusicPlayingChangeListener = void Function(
    bool isPlaying, int index, Map<String, dynamic>);

typedef OnMusicPlayingErrorListener = void Function(
    int index, Map<String, dynamic>);

/// method channel 相关变量的前缀
const METHOD_CHANNEL_PREFIX = "com.williscao.n_music.main";

/// method channel 的名字
const METHOD_CHANNEL_NAME = "$METHOD_CHANNEL_PREFIX/music";

/// method channel 获取手机音频列表
const METHOD_GET_SONG_LIST = "$METHOD_CHANNEL_PREFIX/getSongList";

/// method channel 获取手机音频列表
const METHOD_FORCE_GET_SONG_LIST = "$METHOD_CHANNEL_PREFIX/getSongListForce";

/// method channel 播放指定歌曲
const METHOD_PLAY_SONG = "$METHOD_CHANNEL_PREFIX/playSong";

/// method channel 暂停歌曲
const METHOD_PAUSE_SONG = "$METHOD_CHANNEL_PREFIX/pauseSong";

/// method channel 恢复播放
const METHOD_RESUME_PLAY = "$METHOD_CHANNEL_PREFIX/resumeSong";

/// method channel 恢复播放
const METHOD_RESUME_OR_PAUSE = "$METHOD_CHANNEL_PREFIX/resumeOrPause";

/// method channel 拖拽进度条
const METHOD_SEEK_POSITION = "$METHOD_CHANNEL_PREFIX/seekPosition";

/// method channel 歌曲完成回调
const CALLBACK_COMPLETE_SONG = "$METHOD_CHANNEL_PREFIX/completeSong";

/// method channel 进度更新
const CALLBACK_PROGRESS = "$METHOD_CHANNEL_PREFIX/progress";

/// method channel 播放状态
const CALLBACK_PLAYING_STATE = "$METHOD_CHANNEL_PREFIX/playingState";

/// method channel 音频播放失败
const CALLBACK_PLAYING_ERROR = "$METHOD_CHANNEL_PREFIX/playingError";

class MusicPlayerController {
  var _musicMethodChannel;
  int playingIndex = -1;
  bool isPlaying = false;
  var songs = List<Map<String, dynamic>>();

  var loopMode = SequencePlayModeFactory().createLoopMode();

  List<OnMusicLoadCompleteListener> _onMusicLoadCompleteListeners = [];
  List<OnMusicProgressListener> _onMusicProgressListeners = [];
  List<OnMusicPlayingChangeListener> _onMusicPlayingChangeListeners = [];
  List<OnMusicPlayingErrorListener> _onMusicPlayingErrorListeners = [];

  MusicPlayerController() {
    init();
  }

  init() {
    _musicMethodChannel = MethodChannel(METHOD_CHANNEL_NAME);
    _musicMethodChannel.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) {
    switch (call.method) {
      case CALLBACK_COMPLETE_SONG:
        final String audioPath = call.arguments;
        _onComplete(audioPath);
        break;
      case CALLBACK_PROGRESS:
        final Map<String, dynamic> progressData = jsonDecode(call.arguments);
        _onProgressUpdate(progressData);
        break;
      case CALLBACK_PLAYING_STATE:
        final bool isPlaying = call.arguments;
        _onPlayingStateChange(isPlaying);
        break;
      case CALLBACK_PLAYING_ERROR:
        final String audioPath = call.arguments;
        _onPlayingError(audioPath);
        break;
      default:
        throw UnimplementedError(
            "${call.method} was invoked but isn't implemented by PlatformViewsService");
    }
    return null;
  }

  _onComplete(String audioPath) {
    nLog("_onComplete path : $audioPath");
    nextSong();
  }

  _onProgressUpdate(Map<String, dynamic> progressData) {
    final int progress = progressData["progress"];
    final int buffered = progressData["buffed"];
    final int duration = progressData["duration"];

    nLog(
        "_onProgressUpdate progress : $progress, duration : $duration, progress : $progress, buffed : $buffered");

    _onMusicProgressListeners?.forEach((OnMusicProgressListener listener) {
      listener?.call(progress, buffered, duration);
    });
  }

  _onPlayingStateChange(bool isPlaying) {
    this.isPlaying = isPlaying;
    nLog("_onPlayingStateChange isPlaying : $isPlaying");
    if (playingIndex >= 0 && playingIndex < songs.length) {
      _onMusicPlayingChangeListeners?.forEach((element) {
        element?.call(isPlaying, playingIndex, songs[playingIndex]);
      });
    }
  }

  _onPlayingError(String audioPath) {
    nLog("_onPlayingError audioPath : $audioPath");
    if (playingIndex >= 0 &&
        playingIndex < songs.length &&
        songs[playingIndex]["path"] == audioPath) {
      _onMusicPlayingErrorListeners?.forEach((element) {
        element?.call(playingIndex, songs[playingIndex]);
      });
    }
  }

  /// 获取歌曲列表
  getSongList({bool forceLoad = false}) async {
    final originListSongs = await _musicMethodChannel.invokeListMethod(
        !forceLoad ? METHOD_GET_SONG_LIST : METHOD_FORCE_GET_SONG_LIST);

    songs = List<Map<String, dynamic>>.from(
        originListSongs.map((element) => jsonDecode(element)));

    nLog("getSongList : $songs");

    _onMusicLoadCompleteListeners
        ?.forEach((OnMusicLoadCompleteListener listener) {
      listener?.call(songs);
    });
  }

  /// 播放歌曲
  /// @param index 将要播放的歌曲的index
  playSong(int index) async {
    if (index >= 0 && index < songs.length) {
      playingIndex = index;
      final path = songs[index]["path"];
      await _musicMethodChannel.invokeListMethod(METHOD_PLAY_SONG, path);
    }
  }

  /// 播放歌曲
  /// @param index 将要播放的歌曲的index
  seekTo(double percent) async {
    await _musicMethodChannel.invokeListMethod(
        METHOD_SEEK_POSITION, percent.toInt());
  }

  Map<String, dynamic> curSong() {
    return songs[playingIndex];
  }

  /// 播放下一首歌
  nextSong() async {
    playSong(loopMode.getNextSong(this));
  }

  /// 播放上一首歌
  preSong() async {
    playSong((playingIndex - 1) % songs.length);
  }

  /// 切换循环模式
  switchLoopMode() {
    loopMode = loopMode.getNextMode();
    nLog("current loop mode after switch : ${loopMode.getModeName()}");
    return loopMode.getModeName();
  }

  /// 获取循环模式名字
  getLoopModeName() {
    return loopMode.getModeName();
  }

  /// 暂停播放
  pauseSong() async {
    await _musicMethodChannel.invokeListMethod(METHOD_PAUSE_SONG);
  }

  /// 根据当前状态来决定是暂停还是播放，如果当前是暂停就播放，如果当前是播放就暂停
  pauseOrResume() async {
    await _musicMethodChannel.invokeListMethod(METHOD_RESUME_OR_PAUSE);
  }

  void addOnMusicLoadCompleteListener(OnMusicLoadCompleteListener listener) {
    _onMusicLoadCompleteListeners.add(listener);
  }

  void addOnMusicProgressListener(OnMusicProgressListener listener) {
    _onMusicProgressListeners.add(listener);
  }

  void addOnMusicPlayingChangeListener(OnMusicPlayingChangeListener listener) {
    _onMusicPlayingChangeListeners.add(listener);
  }

  void addOnMusicPlayingErrorListener(OnMusicPlayingErrorListener listener) {
    _onMusicPlayingErrorListeners.add(listener);
  }

  void removeOnMusicLoadCompleteListener(OnMusicLoadCompleteListener listener) {
    _onMusicLoadCompleteListeners.remove(listener);
  }

  void removeOnMusicProgressListener(OnMusicProgressListener listener) {
    _onMusicProgressListeners.remove(listener);
  }

  void removeOnMusicPlayingChangeListener(
      OnMusicPlayingChangeListener listener) {
    _onMusicPlayingChangeListeners.remove(listener);
  }

  void removeOnMusicPlayingErrorListener(OnMusicPlayingErrorListener listener) {
    _onMusicPlayingErrorListeners.remove(listener);
  }
}
