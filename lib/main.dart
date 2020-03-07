import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:n_music/CustomAppBar.dart';
import 'package:n_music/DrawerFrame.dart';
import 'package:n_music/main/Constants.dart';
import 'package:n_music/tabpages/PageCommon.dart';
import 'package:n_music/tabpages/PageEuropeAndAmerica.dart';

import 'PageMain.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle style =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'n_music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<String> _tabs = pageMap.keys.toList();
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: CustomAppBar(
        statusBarHeight: statusBarHeight,
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          onTap: _onTabClick,
          tabs: _tabs.map((String item) {
            return Tab(text: item);
          }).toList(),
          labelColor: Colors.black,
        ),
      ),
      drawer: Drawer(
        child: DrawerFrame(),
      ),
      body: new TabBarView(
        controller: _controller,
        children: _tabs.map((String item) {
          return _getPageByItemName(item);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: themeColor,
        onPressed: _onFloatButtonClick,
      ),
    );
  }

  _onTabClick(int index) {}

  Widget _getPageByItemName(String itemName) {
    return pageMap[itemName] ?? PageCommon(pageName: itemName);
  }

  _onFloatButtonClick() {}
}
