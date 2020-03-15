import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Toast {
  static void show(BuildContext context, String message, {int duration}) {
    OverlayEntry entry = OverlayEntry(builder: (context) {
      return Container(
          color: Colors.transparent,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.7,
          ),
          alignment: Alignment.center,
          child: Center(
              child: Container(
                  color: Colors.black45,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Text(message,
                        style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none)),
                  ))));
    });

    Overlay.of(context).insert(entry);
    Future.delayed(Duration(seconds: duration ?? 2)).then((value) {
      // 移除层可以通过调用OverlayEntry的remove方法。
      entry.remove();
    });
  }
}
