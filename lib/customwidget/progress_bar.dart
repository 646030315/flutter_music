import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n_music/util/constants.dart';
import 'package:n_music/util/n_log.dart';

typedef OnDragEndListener = void Function(double percent);

class ProgressBar extends StatefulWidget {
  final int progressPercent;
  final int bufferedPercent;
  final bool needDrag;
  final OnDragEndListener onSeekToListener;

  ProgressBar(
      {this.progressPercent,
      this.bufferedPercent,
      this.needDrag,
      this.onSeekToListener});

  @override
  State<StatefulWidget> createState() {
    return ProgressBarState();
  }
}

class ProgressBarState extends State<ProgressBar> {
  double _progressWidth = 0;
  double _bufferedWidth = 0;
  double _containerHeight = 30;
  double _horizontalMargin = 10;
  double _ballRadius = 8;

  bool _isDragging = false;
  double _onDragX = 0;

  double _selfWidth = -1;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);

    return GestureDetector(
      onHorizontalDragDown: _onHorizontalDragDown,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,

      onPanDown: _onPanDown,
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      onPanUpdate: _onPanUpdate,


      child: Stack(
        children: <Widget>[
          Container(
              height: _getContainerHeight(),
              alignment: Alignment.center,
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () => nLog("ProgressBarState ${context.size.width}"),
                    child: Container(
                      margin: EdgeInsets.only(
                          left: _getHorizontalMargin(),
                          right: _getHorizontalMargin()),
                      height: 2,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: _getHorizontalMargin(),
                        right: _getHorizontalMargin()),
                    height: 2,
                    width: _bufferedWidth,
                    color: Colors.grey,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: _getHorizontalMargin(),
                        right: _getHorizontalMargin()),
                    height: 2,
                    width: _progressWidth,
                    color: themeColor,
                  ),
                ],
              )),
          _getSeekBall(),
        ],
      ),
    );
  }

  _onPanDown(DragDownDetails details){
    nLog("_onPanDown details.x : ${details.localPosition.dx}");
  }

  _onPanStart(DragStartDetails details){
    nLog("_onPanStart details.x : ${details.localPosition.dx}");
  }

  _onPanEnd(DragEndDetails details){
    nLog("_onPanEnd");
  }

  _onPanUpdate(DragUpdateDetails details){
    nLog("_onPanUpdate details.x : ${details.localPosition.dx}");
  }

  double _getHorizontalMargin() {
    return widget.needDrag ? _horizontalMargin : 0;
  }

  double _getContainerHeight() {
    return widget.needDrag ? _containerHeight : 2;
  }

  _getSeekBall() {
    return widget.needDrag
        ? Container(
            height: _getContainerHeight(),
            width: _ballRadius * 2,
            margin: EdgeInsets.only(
                left: _isDragging ? _onDragX : (_progressWidth + 5)),
            child: Container(
              height: _getContainerHeight(),
              width: _ballRadius * 2,
              child: CustomPaint(
                painter: BallPainter(ballSize: _ballRadius * 2),
              ),
            ),
          )
        : Container(
            height: _getContainerHeight(),
          );
  }

  _onHorizontalDragDown(DragDownDetails details) {
    nLog("_onHorizontalDragStart x : ${details.localPosition.dx}");
    _isDragging = true;
    _onDragX = _getDragX(details.localPosition.dx);
    setState(() {});
  }

  _onHorizontalDragStart(DragStartDetails details) {
    nLog("_onHorizontalDragStart x : ${details.localPosition.dx}");
    _isDragging = true;
    _onDragX = _getDragX(details.localPosition.dx);
    setState(() {});
  }

  _onHorizontalDragEnd(DragEndDetails details) {
    nLog("_onHorizontalDragEnd details : $details");
    _isDragging = false;

    final double seekToPercent =
        (_onDragX - _horizontalMargin) * 100 / _selfWidth;

    widget.onSeekToListener?.call(seekToPercent);
    _onDragX = 0;
  }

  _onHorizontalDragUpdate(DragUpdateDetails details) {
    nLog(
        "_onHorizontalDragUpdate localX : ${details.localPosition.dx}, globalX : ${details.globalPosition.dx}");
    _onDragX = _getDragX(details.localPosition.dx);
    setState(() {});
  }

  _getDragX(double curX) {
    return math.min(math.max(_horizontalMargin - _ballRadius, curX),
        _selfWidth - (_horizontalMargin + _ballRadius));
  }

  _afterBuild(Duration duration) {
    try {
      _selfWidth = context.size.width;
      final double progressTotalWidth =
          context.size.width - _getHorizontalMargin() * 2;
      _progressWidth = (progressTotalWidth * widget.progressPercent) / 100;
      _bufferedWidth = (progressTotalWidth * widget.bufferedPercent) / 100;

      nLog(
          "_afterBuild width : $progressTotalWidth, _progressWidth : $_progressWidth , _bufferedWidth : $_bufferedWidth");
    } catch (e) {
      nLog("exception _afterBuild in ProgressBar : $e");
    }
  }
}

class BallPainter extends CustomPainter {
  final double ballSize;

  BallPainter({this.ballSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), ballSize / 2, paint);
  }

  @override
  bool shouldRepaint(BallPainter oldDelegate) =>
      oldDelegate.ballSize != ballSize;
}
