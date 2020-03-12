import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n_music/util/Constants.dart';
import 'package:n_music/util/NLog.dart';

class ProgressBar extends StatefulWidget {
  final int progressPercent;
  final int bufferedPercent;

  ProgressBar({this.progressPercent, this.bufferedPercent});

  @override
  State<StatefulWidget> createState() {
    return ProgressBarState();
  }
}

class ProgressBarState extends State<ProgressBar> {
  double _progressWidth = 0;
  double _bufferedWidth = 0;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);

    return Stack(
      children: <Widget>[
        InkWell(
          onTap: () => nLog("ProgressBarState ${context.size.width}"),
          child: Container(
            height: 2,
            color: Colors.white,
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
    );
  }

  _afterBuild(Duration duration) {
    final width = context.size.width;
    _progressWidth = (width * widget.progressPercent) / 100;
    _bufferedWidth = (width * widget.bufferedPercent) / 100;

    nLog("_afterBuild width : $width , progressPercent : ${widget.progressPercent}, bufferedPercent: ${widget.bufferedPercent}, _progressWidth : $_progressWidth , _bufferedWidth : $_bufferedWidth ");
  }
}
