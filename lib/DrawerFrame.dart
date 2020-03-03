import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n_music/Toast.dart';
import 'dart:io';

class DrawerFrame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DrawerFrameState();
  }
}

class DrawerFrameState extends State<DrawerFrame> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.grey),
          child: Center(child: Text("Drawer header")),
        ),
        InkWell(
          onTap: _onHomeTap,
          child: ListTile(leading: Icon(Icons.home), title: Text("Home")),
        ),
        InkWell(
          onTap: _onMessageTap,
          child: ListTile(leading: Icon(Icons.message), title: Text("Message")),
        ),
        InkWell(
          onTap: _onPhotoTap,
          child: ListTile(
            leading: Icon(Icons.photo),
            title: Text("Photo"),
          ),
        ),
      ],
    );
  }

  _onHomeTap() {
    // https://qzonestyle.gtimg.cn/aoi/sola/20200225100716_PCSqBR2pS7.png
    print("start _onHomeTap");
    _getIPAddress();
    print("end _onHomeTap");
  }

  Future<int> _asyncExecution() async{
    final result = await _syncExecution();
    return result;
  }

  _syncExecution() {
    print("before _syncExecution");
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    while (true) {
      if (DateTime.now().millisecondsSinceEpoch - currentTime > 1000) {
        break;
      }
    }
    print("after _syncExecution");
    return 10;
  }

  Future<String> _getIPAddress() async {
    print("start _getIPAddress");
    var url = 'https://httpbin.org/ip';
    var httpClient = new HttpClient();

    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        result = data['origin'];
      } else {
        result =
            'Error getting IP address:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting IP address';
    }

    print(result);


//    final currentTime = Future.delayed(Duration(seconds: 2), () => print("print after delay"));

    print("end _getIPAddress");
    return "";
  }

  _onMessageTap() async {
    String result = await _getIPAddress();
    Toast.show(context, "_onMessageTap my ip value $result");
  }

  _onPhotoTap() async {
    String result = await _getIPAddress();
    Toast.show(context, "_onPhotoTap my ip value $result");
  }
}
