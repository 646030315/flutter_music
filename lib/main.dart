import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:n_music/BottomPlayBar.dart';
import 'package:n_music/CustomAppBar.dart';
import 'package:n_music/DrawerFrame.dart';
import 'package:n_music/main/Constants.dart';
import 'package:n_music/main/MusicPlayerController.dart';
import 'package:n_music/tabpages/PageCommon.dart';
import 'package:n_music/tabpages/PageEuropeAndAmerica.dart';

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
        primarySwatch: themeColor,
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
  TabController _tabController;
  MusicPlayerController _musicPlayController;

  Map<String, dynamic> _playingSong;

  @override
  void initState() {
    super.initState();
    _musicPlayController = MusicPlayerController();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );

    print("_MyHomePageState initState");
    _musicPlayController
        ?.addOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
  }

  @override
  void dispose() {
    super.dispose();
    print("_MyHomePageState dispose");
    _musicPlayController
        ?.removeOnMusicPlayingChangeListener(_onMusicPlayingStateChange);
  }

  void _onMusicPlayingStateChange(bool isPlaying, Map<String, dynamic> song) {
    print(
        "main _onMusicPlayingStateChange isPlaying : $isPlaying, song : $song");
    setState(() {
      _playingSong = song;
    });
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
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((String item) {
            return Tab(text: item);
          }).toList(),
          labelColor: Colors.black,
        ),
      ),
      drawer: Drawer(
        child: DrawerFrame(),
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                bottom: _playingSong == null ? 0 : BOTTOM_BAR_HEIGHT),
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((String item) {
                return _getPageByItemName(item);
              }).toList(),
            ),
          ),
          _getBottomBar(),
        ],
      ),
    );
  }

  _getBottomBar() {
    print("_getBottomBar $_playingSong");
    return _playingSong == null
        ? Container()
        : BottomPlayBar(playingSong: _playingSong);
  }

  Widget _getPageByItemName(String itemName) {
    if (itemName == "欧美") {
      return PageEuropeAndAmerica(
        musicPlayListener: _onMusicPlay,
        musicPlayerController: _musicPlayController,
      );
    } else {
      return PageCommon(pageName: itemName);
    }
  }

  _onMusicPlay(Map<String, dynamic> song) {
    if (song != null) {
      setState(() {
        _playingSong = song;
      });
    }
  }
}
