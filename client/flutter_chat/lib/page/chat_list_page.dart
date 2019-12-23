import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/config/app_config.dart';
import 'package:flutter_chat/page/chat_detail_page.dart';
import 'package:flutter_chat/model/user_result.dart';
import 'package:flutter_chat/util/socket_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:oktoast/oktoast.dart';

/**
 * 聊天列表
 */
class ChatListPage extends StatefulWidget {
  final String token;
  final int fromUserId;
  final String userName;

  const ChatListPage({Key key, this.token, this.fromUserId, this.userName})
      : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<User> userList = List();

  bool isShowRight = false; //是否展示右侧的布局

  User toUser;

  SocketManager socketManager;

  AppConfig appConfig;

  @override
  void initState() {
    appConfig = GetIt.instance<AppConfig>();

    //获取聊天列表
    getChatList();
    //连接服务器
    socketManager = GetIt.instance<SocketManager>();
    socketManager.connectWithServer(widget.token).then((bool) {
      if (bool) {
        showToast("连接服务器成功");
      } else {
        showToast("连接服务器失败");
      }
    });
  }

  @override
  void dispose() {
    socketManager.disconnectWithServer();
  }

  @override
  Widget build(BuildContext context) {
    var mobileToplayout;
    if (appConfig.isBigScreen) {
      mobileToplayout = Column(
        children: <Widget>[
          Container(
            height: 80,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Colors.lightBlue,
                  child: Image(
                    image: NetworkImage(
                        "https://cdn.jsdelivr.net/gh/flutterchina/website@1.0/images/flutter-mark-square-100.png"),
                    width: 50,
                    height: 50,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.userName,
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.account_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("在线"),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 25,
                    decoration: BoxDecoration(
                      color: Color(0xffE6E6E6),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        Text(
                          "搜索",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(
                      Icons.add,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
        ],
      );
    } else {
      mobileToplayout = Container(
        color: Colors.white60,
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 15,
            ),
            Text("聊天Demo"),
            Expanded(child: Container()),
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    mobileToplayout,
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Container(
                            height: 60,
                            padding: EdgeInsets.all(10),
                            child: getChatItem(index),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                left: appConfig.isBigScreen ? 0 : 60),
                            child: Divider(
                              color: Colors.black26,
                            ),
                          );
                        },
                        itemCount: userList.length,
                      ),
                    ),
                  ],
                ),
              ),
              appConfig.isBigScreen || isShowRight
                  ? Expanded(
                      child: ChatDetailPage(
                        toUser: toUser,
                        token: widget.token,
                        fromUserId: widget.fromUserId,
                      ),
                      flex: 2,
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  //item
  Widget getChatItem(int index) {
    User user = userList[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        //如果是手机平台的话，点击后跳转到详情页面。否则，修改的是聊天页面。
        if (appConfig.isBigScreen) {
          setState(() {
            toUser = user;
            isShowRight = true;
          });
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ChatDetailPage(
              toUser: user,
              token: widget.token,
              fromUserId: widget.fromUserId,
            );
          }));
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
            child: Image(
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
                Text("${user.username}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  getChatList() async {
    Dio dio = Dio(BaseOptions(
        baseUrl: GetIt.instance<AppConfig>().apiHost,
        headers: {'Authorization': 'Bearer ${widget.token}'}));

    Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(
      "/chat_list",
    );

    if (response != null &&
        response.data != null &&
        response.data['code'] == 1) {
      List list = response.data['data'];
      list?.forEach((json) {
        userList.add(User.fromJson(json));
      });

      setState(() {});
    }
  }
}
