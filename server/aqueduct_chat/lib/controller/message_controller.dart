import 'dart:convert';

import 'package:aqueduct_chat/aqueduct_chat.dart';
import 'package:aqueduct_chat/model/base_result.dart';
import 'package:aqueduct_chat/model/message.dart';

/**
 * 消息处理
 */
class MessageController extends ResourceController {
  final ManagedContext context;

  MessageController(this.context);

//  /**
//   * 发送消息给某一个用户(不需要这样搞，用webSocket来做就行了)
//   */
//  @Operation.post()
//  Future<Response> postMessage() async {
//    //获取body里面的内容
//    Map<String, dynamic> body =
//        await request.body.decode() as Map<String, dynamic>;
//    //发送者的id
//    int fromUserId = request.authorization.ownerID;
//    //接收者的id
//    int toUserId = body['toUserId'] as int;
//    //消息内容
//    String msg_content = body['msg_content'] as String;
//    //消息类型
////    int msg_type=body['msg_type'] as int;
//
//    connections.keys.forEach((key) {
//      if (key == toUserId) {
//        connections[key].add(msg_content);
//        print(
//            "服务器进行中转消息： fromUserId:$fromUserId,toUserId:$toUserId,msg_content: $msg_content");
//      }
//    });
//
//    return Response.ok(BaseResult(code: 1, msg: "发送消息成功", data: {
//      'fromUserId': fromUserId,
//      'toUserId': toUserId,
//      'msg_content': msg_content
//    }));
//  }

  /**
   * 查询聊天记录
   * 1。fromId和toId都为空，没有指定用户，相当于查看所有人的记录
   * 2。fromId不为空，toId为空，查看某个人所发送的聊天记录
   * 3。fromId为空，toId不为空，查看某个人所接收的聊天记录
   * 4。fromId不为空，toId不为空，查看两个人之间的聊天记录
   */
  @Operation.get()
  Future<Response> getMessage({
    @Bind.query('fromId') int fromId,
    @Bind.query('toId') int toId,
  }) async {
    List<Message> messageList;
    Query<Message> query;

    if (fromId == null && toId == null) {
      query = await Query<Message>(context)
        ..sortBy((message) {
          return message.sendTime;
        }, QuerySortOrder.ascending);
    } else if (fromId != null && toId == null) {
      query = Query<Message>(context)
        ..where((message) {
          return message.fromUserId;
        }).equalTo(fromId)
        ..sortBy((message) {
          return message.sendTime;
        }, QuerySortOrder.ascending);
    } else if (fromId == null && toId != null) {
      query = Query<Message>(context)
        ..where((message) {
          return message.toUserId;
        }).equalTo(toId)
        ..sortBy((message) {
          return message.sendTime;
        }, QuerySortOrder.ascending);
    } else {
      query = Query<Message>(context)
        ..where((message) {
          return message.toUserId;
        }).oneOf([fromId, toId])
        ..where((message) {
          return message.fromUserId;
        }).oneOf([fromId, toId])
        ..sortBy((message) {
          return message.sendTime;
        }, QuerySortOrder.ascending);
    }
    messageList = await query.fetch();

    messageList.forEach((message) {
      if (message.fromUserId == request.authorization.ownerID) {
        message.selfUser = true;
      } else {
        message.selfUser = false;
      }
//      print("${message.toJson()}");
    });

//    print("messageList:$messageList");
    return Response.ok(
      BaseResult(
        code: 1,
        msg: "获取消息记录",
        data: messageList,
      ),
    );
  }
}
