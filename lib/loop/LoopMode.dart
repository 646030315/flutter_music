import 'dart:math';

import 'package:n_music/main/MusicPlayerController.dart';

abstract class LoopMode {
  /// 获取当前循环模式下的下一首
  int getNextSong(MusicPlayerController controller);

  /// 获取当前循环模式下的下一种循环模式，模式切换
  LoopMode getNextMode();

  /// 获取当前循环模式的名称
  String getModeName();
}

abstract class LoopModeFactory {
  /// 创建循环模式
  LoopMode createLoopMode();
}

class SequencePlayModeFactory extends LoopModeFactory {
  @override
  LoopMode createLoopMode() {
    return SequencePlayMode();
  }
}

class SequencePlayMode extends LoopMode {
  @override
  String getModeName() {
    return "列表循环";
  }

  @override
  LoopMode getNextMode() {
    return SinglePlayMode();
  }

  @override
  int getNextSong(MusicPlayerController controller) {
    return (controller.playingIndex + 1) % controller.songs.length;
  }
}

class SinglePlayModeFactory extends LoopModeFactory {
  @override
  LoopMode createLoopMode() {
    return SinglePlayMode();
  }
}

class SinglePlayMode extends LoopMode {
  @override
  String getModeName() {
    return "单曲循环";
  }

  @override
  LoopMode getNextMode() {
    return RandomPlayMode();
  }

  @override
  int getNextSong(MusicPlayerController controller) {
    return controller.playingIndex % controller.songs.length;
  }
}

class RandomPlayModeFactory extends LoopModeFactory {
  @override
  LoopMode createLoopMode() {
    return RandomPlayMode();
  }
}

class RandomPlayMode extends LoopMode {
  Random _random = Random();

  @override
  String getModeName() {
    return "随机播放";
  }

  @override
  LoopMode getNextMode() {
    return SequencePlayMode();
  }

  @override
  int getNextSong(MusicPlayerController controller) {
    int tempIndex = controller.playingIndex;
    while (tempIndex == controller.playingIndex) {
      tempIndex =
          _random.nextInt(controller.songs.length) % controller.songs.length;
    }
    return tempIndex;
  }
}
