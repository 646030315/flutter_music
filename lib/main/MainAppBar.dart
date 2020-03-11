import 'package:flutter/material.dart';
import 'package:n_music/Toast.dart';
import 'package:n_music/main/Constants.dart';
import 'package:n_music/main/NLog.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget bottom;
  final statusBarHeight;

  MainAppBar({this.bottom, this.statusBarHeight});

  @override
  State<StatefulWidget> createState() {
    return MainAppBarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(statusBarHeight +
      TITLE_BAR_HEIGHT +
      (bottom?.preferredSize?.height ?? 0.0));
}

class MainAppBarState extends State<MainAppBar> {
  var _selectedTab = SelectedTabType.MUSIC;

  void _handleDrawerOpen() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE61A1A),
      ),
      padding: EdgeInsets.only(top: widget.statusBarHeight),
      height: widget.preferredSize.height,
      child: Column(
        children: <Widget>[
          Container(
            height: TITLE_BAR_HEIGHT,
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: _handleDrawerOpen,
                  child: Container(
                    width: 40,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    margin: const EdgeInsets.only(left: 11),
                    child: Image.asset("ic_menu.png",
                        width: 30, height: 30, alignment: Alignment.center),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () => setState(() {
                          _selectedTab = SelectedTabType.MUSIC;
                        }),
                        child: Image.asset(_getTabImage(SelectedTabType.MUSIC),
                            width: 60, height: 60, alignment: Alignment.center),
                      ),
                      InkWell(
                        onTap: () => setState(() {
                          _selectedTab = SelectedTabType.FRIEND;
                        }),
                        child: Image.asset(_getTabImage(SelectedTabType.FRIEND),
                            width: 60, height: 60, alignment: Alignment.center),
                      ),
                      InkWell(
                        onTap: () => setState(() {
                          _selectedTab = SelectedTabType.DISCOVER;
                        }),
                        child: Image.asset(
                            _getTabImage(SelectedTabType.DISCOVER),
                            width: 60,
                            height: 60,
                            alignment: Alignment.center),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: _onSearchClick,
                    child: Image.asset("icon_search.png",
                        width: 25, height: 25, alignment: Alignment.center),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: widget.bottom.preferredSize.height,
            child: widget.bottom,
          ),
        ],
      ),
    );
  }

  _getTabImage(SelectedTabType type) {
    var image;
    if (_selectedTab == type) {
      if (_selectedTab == SelectedTabType.MUSIC) {
        image = "actionbar_music_selected.png";
      } else if (_selectedTab == SelectedTabType.FRIEND) {
        image = "actionbar_friends_selected.png";
      } else if (_selectedTab == SelectedTabType.DISCOVER) {
        image = "actionbar_discover_selected.png";
      }
    } else {
      if (type == SelectedTabType.MUSIC) {
        image = "actionbar_music_prs.png";
      } else if (type == SelectedTabType.FRIEND) {
        image = "actionbar_friends_prs.png";
      } else if (type == SelectedTabType.DISCOVER) {
        image = "actionbar_discover_prs.png";
      }
    }

    nLog(image);
    return image;
  }

  _onSearchClick() {
    Toast.show(context, "_onSearchClick");
  }
}

enum SelectedTabType { MUSIC, FRIEND, DISCOVER }
