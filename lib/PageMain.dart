import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n_music/main/Constants.dart';
import 'package:permission_handler/permission_handler.dart';

class PageMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageMainState();
  }
}

class PageMainState extends State<PageMain>
    with SingleTickerProviderStateMixin {
  int _permissionState = PERMISSION_NONE;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 模拟耗时任务加载
    new Future.delayed(const Duration(seconds: 3), () => _checkPermissions());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String content = "";
    if (_permissionState == PERMISSION_GRANT) {
      content = "This is page main";
    } else if (_permissionState == PERMISSION_NONE) {
      content = WRITE_PERMISSION_LACK_WARN;
    } else {
      content = PERMISSION_CHECK;
    }

    if (_permissionState == PERMISSION_GRANT) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Divider(
            height: 1,
            color: Color(0xFFE0E0E0),
          ),
        ],
      );
    } else {
      return Text(WRITE_PERMISSION_LACK_WARN);
    }
  }

  /// 权限检测，查看是否需要弹框请求用户权限
  _checkPermissions() async {
    PermissionStatus status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (status != PermissionStatus.granted) {
      if (status == PermissionStatus.disabled ||
          status == PermissionStatus.neverAskAgain) {
        // 如果功能无法使用或者用户设置不在弹窗，这里不做任何事情，不弹框，不请求
        setState(() {
          _permissionState = PERMISSION_DENY;
        });
      } else if (status == PermissionStatus.denied) {
        _requestPermission();
      }
    } else {
      setState(() {
        _permissionState = PERMISSION_GRANT;
      });
    }
  }

  /// 动态请求权限，目前需要的权限是存储权限
  _requestPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    bool granted = true;
    permissions.forEach((key, value) {
      if (value != PermissionStatus.granted) {
        granted = false;
      }
    });

    setState(() {
      _permissionState = granted ? PERMISSION_GRANT : PERMISSION_DENY;
    });
  }

  _onTabClick(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _getTabView() {
//    return Center(
//      child: Text(_tabs[_selectedIndex]),
//    );
  }
}
