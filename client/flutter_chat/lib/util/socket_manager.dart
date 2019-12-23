import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/config/app_config.dart';
import 'package:flutter_chat/model/message_result.dart';
import 'package:get_it/get_it.dart';
import 'package:web_socket_channel/io.dart';

/**
 * 管理socket连接
 */
class SocketManager {
  IOWebSocketChannel channel;

  List<Message> messageList = List();

  ObserverList<onReceiveMessage> observerList =
      ObserverList<onReceiveMessage>();

  //与服务器建立连接
  Future<bool> connectWithServer(String token) async {
    debugPrint(
        "跟服务器建立连接。。。" + GetIt.instance<AppConfig>().apiHost.substring(7));
    channel = IOWebSocketChannel.connect(
      "ws://" + GetIt.instance<AppConfig>().apiHost.substring(7) + "/connect",
      headers: {'Authorization': 'Bearer ${token}'},
    );

    channel.stream.listen((message) {
      debugPrint("收到服务器的消息：" + message.toString());
      messageList.add(Message.fromJson(json.decode(message)));

      observerList.forEach((onReceiveMessage listener) {
        listener(json.decode(message));
      });
    });
    print("服务器连接是否成功：${channel != null}");
    if (channel != null) {
      //认为连接成功
      return true;
    }
    return false;
  }

  //断开连接
  disconnectWithServer() async {
    channel.sink.close();
  }

  //发送消息
  Future<bool> sendMessage(Map<String, dynamic> data) async {
    channel.sink.add(json.encode(data));
  }

  //外部添加监听
  addListener(onReceiveMessage listener) {
    if (observerList.contains(listener)) {
      return;
    }
    observerList.add(listener);
  }

  removeListener(onReceiveMessage listener) {
    observerList.remove(listener);
  }
}

typedef onReceiveMessage(Map<String, dynamic> json); //接收到服务器的消息
