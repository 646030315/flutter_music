
/// 格式音乐时长
String formatSongTimeLength(final int duration) {
  int minute = duration ~/ 60;
  int second = duration % 60;

  return "${minute <= 9 ? "0" : ""}$minute : ${second <= 9 ? "0" : ""}$second";
}
