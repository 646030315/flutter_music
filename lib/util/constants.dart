import 'package:flutter/material.dart';
import 'package:n_music/tabpages/page_common.dart';
import 'package:n_music/tabpages/page_europe_and_america.dart';

const double AVATAR_SIZE = 60;
const double BLUR_SIGMA_X = 10;
const double BLUR_SIGMA_Y = 10;
const double TITLE_BAR_HEIGHT = 56;
const double BOTTOM_BAR_HEIGHT = 50;
const double DIVIDER_HEIGHT = 1;

const MaterialColor themeColor = MaterialColor(
  _redPrimaryValue,
  <int, Color>{
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(_redPrimaryValue),
    600: Color(0xFFE53935),
    700: Color(0xFFD32F2F),
    800: Color(0xFFC62828),
    900: Color(0xFFB71C1C),
  },
);
const int _redPrimaryValue = 0xFFE61A1A;

const Color bottomBarColor = Color(0xeeF7F7F7);

const String AVATAR_URI = "assets/avatar.jpg";

// 读写权限检查相关常量
const int PERMISSION_NONE = 0;
const int PERMISSION_GRANT = 1;
const int PERMISSION_DENY = 2;
const String WRITE_PERMISSION_LACK_WARN = "需要授权之后才能用";
const String PERMISSION_CHECK = "需要授权之后才能用";

final pageMap = <String, Widget>{
  "欧美": PageEuropeAndAmerica(),
  "内地": PageCommon(pageName: "内地"),
  "港台": PageCommon(pageName: "港台"),
  "韩国": PageCommon(pageName: "韩国"),
  "日本": PageCommon(pageName: "日本"),
  "民谣": PageCommon(pageName: "民谣"),
  "摇滚": PageCommon(pageName: "摇滚"),
  "销量": PageCommon(pageName: "销量"),
  "热歌": PageCommon(pageName: "热歌"),
};

