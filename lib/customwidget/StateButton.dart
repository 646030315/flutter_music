import 'package:flutter/material.dart';

import '../util/NLog.dart';

typedef OnTapCallback = void Function();
typedef OnTapUpCallback = void Function(TapUpDetails event);
typedef OnTapDownCallback = void Function(TapDownDetails event);

/// 具有点击态的按钮，根据点击状态展示不同图片
// ignore: must_be_immutable
class StateButton extends StatefulWidget {
  final String _imagePre;
  final String _imageNor;

  final double width;
  final double height;

  final bool isSelectButtonMode;

  final OnTapCallback onTap;
  final OnTapCallback onTapCancel;
  final OnTapUpCallback onTapUp;
  final OnTapDownCallback onTapDown;

  StateButton(this._imageNor, this._imagePre,
      {this.onTap,
      this.onTapCancel,
      this.onTapUp,
      this.onTapDown,
      this.isSelectButtonMode = false,
      this.height = 40,
      this.width = 40});

  @override
  State<StatefulWidget> createState() {
    return StateButtonState();
  }
}

class StateButtonState extends State<StateButton> {
  static const TAG = "PressStateButton";

  var isPress = false;

  @override
  Widget build(BuildContext context) {

    final double width = MediaQuery.of(context).size.width;

    nLog("StateButtonState width: $width");

    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: _getImage(),
    );
  }

  _getImage() {
    String imageString;
    if (isPress && widget._imagePre != null && widget._imagePre.isNotEmpty) {
      imageString = widget._imagePre;
    } else if (!isPress &&
        widget._imageNor != null &&
        widget._imageNor.isNotEmpty) {
      imageString = widget._imageNor;
    }

    if (imageString != null && imageString.isNotEmpty) {
      return Image.asset(
        imageString,
        width: widget.width,
        height: widget.height,
      );
    }
    return null;
  }

  _onTap() {
    nLog("$TAG _onTap");

    if (widget.isSelectButtonMode) {
      select();
    }

    if (widget.onTap != null) {
      widget.onTap();
    }
  }

  _onTapDown(TapDownDetails event) {
    nLog("$TAG _onTapDown");

    if (!widget.isSelectButtonMode) {
      select();
    }

    if (widget.onTapDown != null) {
      widget.onTapDown(event);
    }
  }

  _onTapCancel() {
    nLog("$TAG _onTapCancel");
    if (!widget.isSelectButtonMode) {
      unSelect();
    }

    if (widget.onTapCancel != null) {
      widget.onTapCancel();
    }
  }

  _onTapUp(TapUpDetails event) {
    nLog("$TAG _onTapUp");
    if (!widget.isSelectButtonMode) {
      unSelect();
    }

    if (widget.onTapUp != null) {
      widget.onTapUp(event);
    }
  }

  select() {
    setState(() {
      isPress = true;
    });
  }

  unSelect() {
    setState(() {
      isPress = false;
    });
  }
}
