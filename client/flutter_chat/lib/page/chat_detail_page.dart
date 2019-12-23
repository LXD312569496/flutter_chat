import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/config/app_config.dart';
import 'package:flutter_chat/model/message_result.dart';
import 'package:flutter_chat/model/user_result.dart';
import 'package:flutter_chat/util/socket_manager.dart';
import 'package:flutter_chat/widget/message_item.dart';
import 'package:get_it/get_it.dart';

/**
 * 聊天详情页面
 */
class ChatDetailPage extends StatefulWidget {
  String token;
  int fromUserId; //自己的id
  User toUser; //想聊天的对象

  ChatDetailPage(
      {@required this.token, @required this.fromUserId, @required this.toUser});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  String text = "";

  TextEditingController inputController = TextEditingController(text: "");
  ScrollController scrollController = new ScrollController();

  List<Message> messageList = List();
  onReceiveMessage listener;

  AppConfig appConfig = GetIt.instance<AppConfig>();

  @override
  void initState() {
    print("ChatDetailPage initState");

    listener = (Map<String, dynamic> json) {
      if (mounted) {
        setState(() {
          print("messageList增加一条消息");
          Message newMessage = Message.fromJson(json);
          if (newMessage.fromUserId == widget.fromUserId ||
              newMessage.toUserId == widget.fromUserId) {
            messageList.add(newMessage);
//            calculateTimeVisibility(messageList);
          }
        });
        Future.delayed(Duration(milliseconds: 50), () {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        });
      }
    };

    //添加监听
    GetIt.instance<SocketManager>().addListener(listener);
    //获取聊天记录
    getChatHistory();
  }

  @override
  void didUpdateWidget(ChatDetailPage oldWidget) {
    print("didUpdateWidget");
    //添加监听
    GetIt.instance<SocketManager>().addListener(listener);
    //获取聊天记录
    getChatHistory();
  }

  @override
  void didChangeDependencies() {
    print("didChangeDependencies");
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //移除监听
    GetIt.instance<SocketManager>().removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("ChatDetailPage build");
    //控制AppBar的显示
    var appbar = widget.toUser == null
        ? null
        : AppBar(
            automaticallyImplyLeading: appConfig.isBigScreen ? false : true,
            title: Text("${widget.toUser.username}"),
            centerTitle: false,
          );
    //控制底部的输入布局显示
    var inputLayout = appConfig.isBigScreen
        ? Expanded(
            flex: 2,
            child: TextFormField(
              controller: inputController,
              decoration: InputDecoration(border: InputBorder.none),
              onFieldSubmitted: (text) {
                if (appConfig.isBigScreen) {
                  sendMessage();
                }
              },
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: inputController,
                  onFieldSubmitted: (text) {
                    if (appConfig.isBigScreen) {
                      sendMessage();
                    }
                  },
                ),
              ),
              RaisedButton(
                onPressed: () {
                  sendMessage();
                },
                child: Text("发送"),
              ),
            ],
          );

    return Scaffold(
      appBar: appbar,
      body: Container(
        color: Color(0xffF3F3F3),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 8,
              child: CupertinoScrollbar(
                child: ListView.builder(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    return MessageItem(messageList[index]);
                  },
                  itemCount: messageList.length,
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.black,
            ),
            inputLayout
          ],
        ),
      ),
    );
  }

  sendMessage() async {
    //发送消息
    Map<String, dynamic> data = {
      'toUserId': widget.toUser.id,
      'msg_content': inputController.text.toString(),
      'msg_type': 1,
    };

    GetIt.instance<SocketManager>().sendMessage(data);

    //清空editText
    inputController.clear();

    debugPrint("向服务器发送消息:$data");
  }

  getChatHistory() async {
    //前置条件不满足，不请求接口。场景：桌面端，刚进去页面的时候，没有选择具体的聊天人，但是这个页面还是需要显示，只是没有数据。
    if (widget.token.isNotEmpty == false || widget.toUser == null) {
      return;
    }
    Dio dio = Dio(BaseOptions(
        baseUrl: GetIt.instance<AppConfig>().apiHost,
        headers: {'Authorization': 'Bearer ${widget.token}'}));

    Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(
      "/message",
      queryParameters: {
        'fromId': widget.fromUserId,
        'toId': widget.toUser?.id,
      },
    );

    if (response != null &&
        response.data != null &&
        response.data['code'] == 1) {
      var result = response.data['data'];
      messageList.clear();
      result?.forEach((json) {
        messageList.add(Message.fromJson(json));
      });
      calculateTimeVisibility(messageList);
    }

    setState(() {});

    Future.delayed(Duration(milliseconds: 50), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }
}

/**
 * 微信聊天时间显示规则：
    当天的消息，以每5分钟为一个跨度显示时间；
    消息超过1天、小于1周，显示为“星期 消息发送时间”；
    消息大于1周，显示为“日期 消息发送时间
 */
//计算消息时间的可见性
calculateTimeVisibility(List<Message> list) {
  if (list.isEmpty) {
    return;
  }
  DateTime lastVisiableTime = list.last.sendTime;
  list.last.timeVisility = true;

  //倒序遍历
  for (int i = list.length - 1; i >= 0; i--) {
    Message message = list[i];
//    print(
//        "message.sendTime.difference(DateTime.now()).inDays:${message.sendTime.difference(DateTime.now()).inDays}");

    int diffDays = lastVisiableTime.difference(message.sendTime).inDays;
    if (diffDays == 0) {
      //同一天
      if (lastVisiableTime.difference(message.sendTime).inMinutes < 5) {
        //间隔小于上一次5分钟
        message.timeVisility = false;
      } else {
        //间隔大于上一次5分钟
        lastVisiableTime = message.sendTime;
        message.timeVisility = true;
      }
    } else if (diffDays < 7) {
      //超过1天、小于1周
      message.timeVisility = true;
      lastVisiableTime = message.sendTime;
    } else {
      //消息大于1周
      message.timeVisility = true;
      lastVisiableTime = message.sendTime;
    }
  }
}
