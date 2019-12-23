class Message {

  /**
   * 后端返回字段
   */
  int id;
  int fromUserId; //发送者id
  int toUserId; //接受者id
  String content; //消息内容
  int type; //消息类型
  DateTime sendTime; //发送时间
  bool selfUser;

  /**
   * 前端自定义字段
   */
  bool timeVisility;//时间可见性

  Message();

  Message.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        fromUserId = json['fromUserId'],
        toUserId = json['toUserId'],
        content = json['content'],
        type = json['type'],
        selfUser = json['selfUser'],
        sendTime = DateTime.parse(json['sendTime']);

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
    };
  }
}
