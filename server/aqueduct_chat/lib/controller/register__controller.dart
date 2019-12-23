import 'package:aqueduct_chat/aqueduct_chat.dart';
import 'package:aqueduct_chat/model/base_result.dart';
import 'package:aqueduct_chat/model/user.dart';

/**
 * 注册接口
 */
class RegisterController extends ResourceController {
  final AuthServer authServer;
  final ManagedContext context;

  RegisterController(this.authServer, this.context);

  @Operation.post()
  Future<Response> createUser(@Bind.body() User user) async {
    //检查条件
    if (user.username.isNotEmpty != true || user.password.isNotEmpty != true) {
      return Response.ok(
        BaseResult(
          code: 1,
          msg: '注册失败：username and password required',
        ),
      );
    }

    //判断用户是否存在
    Query<User> query = Query<User>(context)
      ..where((u) {
        return u.username;
      }).equalTo(user.username);
    if (await query.fetchOne() != null) {
      return Response.ok(
        BaseResult(
          code: 1,
          msg: '注册失败：user has already exist',
        ),
      );
    }

    //插入数据库
    user
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt);

    var result = await Query(context, values: user).insert();

    return Response.ok(
      BaseResult(
        code: 1,
        data: result,
        msg: "注册成功",
      ),
    );
  }
}
