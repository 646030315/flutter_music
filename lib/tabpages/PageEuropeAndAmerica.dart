import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n_music/main/Constants.dart';

class PageEuropeAndAmerica extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageEuropeAndAmericaState();
  }
}

class PageEuropeAndAmericaState extends State<PageEuropeAndAmerica> {
  var datas = <String>[
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈",
    "爱的魔力转圈圈"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Divider(
            height: 1,
            color: Color(0xFFFAFAFA),
          ),
          Container(
            margin: EdgeInsets.only(top: 1),
            child: ListView.builder(
                itemCount: datas.length,
                itemBuilder: (context, index) {
                  return _getItemView(context, index);
                }),
          ),
        ],
      ),
    );
  }

  Widget _getItemView(BuildContext context, int index) {
    return Container(
      color: Colors.white,
      height: 80,
      alignment: Alignment.center,
      child: ListTile(
        title: Text(
          datas[index],
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        subtitle: Text(
          datas[index],
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Icon(Icons.add),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(AVATAR_URI),
        ),
      ),
    );
  }
}
