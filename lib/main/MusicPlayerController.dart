import 'dart:convert';

import 'package:flutter/services.dart';

typedef OnMusicLoadCompleteListener = void Function(
    List<Map<String, dynamic>> songList);

typedef OnMusicProgressListener = void Function(int progress);

typedef OnMusicPlayingChangeListener = void Function(
    bool isPlaying, int index, Map<String, dynamic>);

/// method channel 相关变量的前缀
const METHOD_CHANNEL_PREFIX = "com.williscao.n_music.main";

/// method channel 的名字
const METHOD_CHANNEL_NAME = "$METHOD_CHANNEL_PREFIX/music";

/// method channel 获取手机音频列表
const METHOD_GET_SONG_LIST = "$METHOD_CHANNEL_PREFIX/getSongList";

/// method channel 播放指定歌曲
const METHOD_PLAY_SONG = "$METHOD_CHANNEL_PREFIX/playSong";

/// method channel 暂停歌曲
const METHOD_PAUSE_SONG = "$METHOD_CHANNEL_PREFIX/pauseSong";

/// method channel 恢复播放
const METHOD_RESUME_PLAY = "$METHOD_CHANNEL_PREFIX/resumeSong";

/// method channel 恢复播放
const METHOD_RESUME_OR_PAUSE = "$METHOD_CHANNEL_PREFIX/resumeOrPause";

/// method channel 歌曲完成回调
const CALLBACK_COMPLETE_SONG = "$METHOD_CHANNEL_PREFIX/completeSong";

/// method channel 进度更新
const CALLBACK_PROGRESS = "$METHOD_CHANNEL_PREFIX/progress";

/// method channel 播放状态
const CALLBACK_PLAYING_STATE = "$METHOD_CHANNEL_PREFIX/playingState";

class MusicPlayerController {
  var _musicMethodChannel;
  int _playingIndex = -1;
  var _songs = List<Map<String, dynamic>>();

  List<OnMusicLoadCompleteListener> _onMusicLoadCompleteListeners = [];
  List<OnMusicProgressListener> _onMusicProgressListeners = [];
  List<OnMusicPlayingChangeListener> _onMusicPlayingChangeListeners = [];

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
      default:
        throw UnimplementedError(
            "${call.method} was invoked but isn't implemented by PlatformViewsService");
    }
    return null;
  }

  _onComplete(String audioPath) {
    print("_onComplete path : $audioPath");
    if (_playingIndex >= 0 &&
        _playingIndex < _songs.length &&
        _songs[_playingIndex]["path"] == audioPath) {
      playSong(_playingIndex + 1 % _songs.length);
    }
  }

  _onProgressUpdate(Map<String, dynamic> progressData) {
    final int progress = progressData["progress"];
    final int duration = progressData["duration"];
    final int percent = progress * 100 ~/ duration;
    print(
        "_onProgressUpdate progress : $progress, duration : $duration, percent : $percent");

    _onMusicProgressListeners.forEach((OnMusicProgressListener listener) {
      listener(percent);
    });
  }

  _onPlayingStateChange(bool isPlaying) {
    print("_onPlayingStateChange isPlaying : $isPlaying");
    if (_playingIndex >= 0 && _playingIndex < _songs.length) {
      _onMusicPlayingChangeListeners.forEach((element) {
        element.call(isPlaying, _playingIndex, _songs[_playingIndex]);
      });
    }
  }

  /// 获取歌曲列表
  getSongList() async {
    final songs =
        await _musicMethodChannel.invokeListMethod(METHOD_GET_SONG_LIST);

    _songs = List<Map<String, dynamic>>.from(
        songs.map((element) => jsonDecode(element)));

    print("getSongList : $_songs");

    _onMusicLoadCompleteListeners
        .forEach((OnMusicLoadCompleteListener listener) {
      listener(_songs);
    });
  }

  /// 播放歌曲
  /// @param index 将要播放的歌曲的index
  playSong(int index) async {
    if (index >= 0 && index < _songs.length) {
      _playingIndex = index;
      final path = _songs[index]["path"];
      await _musicMethodChannel.invokeListMethod(METHOD_PLAY_SONG, path);
    }
  }

  /// 播放下一首歌
  nextSong() async {
    if (_playingIndex >= 0 && _playingIndex < _songs.length) {
      final nextSongIndex = _playingIndex + 1 % _songs.length;
      playSong(nextSongIndex);
    }
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
}
