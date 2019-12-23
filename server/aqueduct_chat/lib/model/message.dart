import 'package:aqueduct_chat/aqueduct_chat.dart';

/**
 * 对应每一条聊天记录
 */
class Message extends ManagedObject<_Message> implements _Message {
  @Serialize(input: true,output: true)
  bool selfUser; //判断是不是当前用户

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'content': content,
      'type': type,
      'sendTime': sendTime.toUtc().toString(),
      'selfUser': selfUser
    };
  }
}

class _Message {
  @Column(primaryKey: true, autoincrement: true)
  int id;

  @Column()
  int fromUserId; //发送者id
  @Column()
  int toUserId; //接受者id
  @Column()
  String content; //消息内容
  @Column()
  int type; //消息类型
  @Column()
  DateTime sendTime; //发送时间
}
