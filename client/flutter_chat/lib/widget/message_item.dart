import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/model/message_result.dart';
import 'package:flutter_chat/util/date_util.dart';

/**
 * 聊天信息的布局
 */
class MessageItem extends StatelessWidget {
  final Message message;

  MessageItem(this.message);

  @override
  Widget build(BuildContext context) {
//    Widget timeWidget = Visibility(
//      child: Container(
//        child: Text(DateUtil.getNewChatTime(message.sendTime)),
//      ),
//      visible: message.timeVisility == true,
//    );
    Widget messageWidget;
    if (message.selfUser == true) {
      messageWidget = MineMessageItem(message);
    } else {
      messageWidget = OtherMessageItem(message);
    }

    return Column(
      children: <Widget>[
//        timeWidget,
        messageWidget
      ],
    );
  }
}

/**
 * 自己
 */
class MineMessageItem extends StatelessWidget {
  final Message message;

  MineMessageItem(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
//                Text("username"),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  color: Color(0xff9FE658),
                  child: Text(message.content),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Image(
              width: 35,
              height: 35,
              image: NetworkImage(
                  "https://cdn.jsdelivr.net/gh/flutterchina/website@1.0/images/flutter-mark-square-100.png"),
            ),
          ),
        ],
      ),
    );
  }
}

/**
 * 别人的Item
 */
class OtherMessageItem extends StatelessWidget {
  final Message message;

  OtherMessageItem(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Image(
              width: 35,
              height: 35,
              image: NetworkImage(
                  "https://cdn.jsdelivr.net/gh/flutterchina/website@1.0/images/flutter-mark-square-100.png"),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("username"),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  color: Colors.white,
                  child: Text(message.content),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
