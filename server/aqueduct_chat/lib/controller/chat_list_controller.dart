import 'package:aqueduct_chat/aqueduct_chat.dart';
import 'package:aqueduct_chat/model/base_result.dart';
import 'package:aqueduct_chat/model/user.dart';

/**
 * 获取聊天列表
 */
class ChatListController extends ResourceController {
  final ManagedContext context;

  ChatListController(this.context);

  @Operation.get()
  Future<Response> getFriends() async {
    //todo:这里先搞成获取所有user
    int fromUserId = request.authorization.ownerID;
    Query<User> query = Query<User>(context)
      ..where((user) {
        return user.id;
      }).notEqualTo(fromUserId); //过滤掉自己
    List<User> users = await query.fetch();

    return Response.ok(
      BaseResult(
        code: 1,
        msg: "获取好友列表",
        data: users,
      ),
    );
  }
}
