import 'package:flutter/material.dart';

class PageCommon extends StatefulWidget {
  final pageName;

  PageCommon({this.pageName});

  @override
  State<StatefulWidget> createState() {
    return PageCommonState();
  }
}

class PageCommonState extends State<PageCommon> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity, height: double.infinity, child: Center(child: Text("${widget.pageName ?? ""}榜单")));
  }
}
