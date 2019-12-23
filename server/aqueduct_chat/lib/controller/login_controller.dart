import 'dart:convert';

import 'package:aqueduct_chat/aqueduct_chat.dart';
import 'package:aqueduct_chat/model/base_result.dart';
import 'package:aqueduct_chat/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:http/src/response.dart' as res;

/**
 * 登录接口
 */
class LoginController extends ResourceController {
  final ManagedContext context;

  LoginController(this.context);

  @Operation.post()
  Future<Response> login(@Bind.body() User user) async {
    String msg = "登录异常";
    //查询数据库是否存在这个用户
    var query = Query<User>(context)
      ..where((u) => u.username).equalTo(user.username);
    User result = await query.fetchOne();

    if (result == null) {
      msg = "用户不存在";
    } else {
      //通过auth/token获取token。登录成功的话，返回token
      var clientId = "com.donggua.chat";
      var clientSecret = "dongguasecret";
      var body =
          "username=${user.username}&password=${user.password}&grant_type=password";
      var clientCredentials =
          Base64Encoder().convert("$clientId:$clientSecret".codeUnits);

      res.Response response =
          await http.post("http://127.0.0.1:8888/auth/token",
              headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "Authorization": "Basic $clientCredentials"
              },
              body: body);

      if (response.statusCode == 200) {
        var map = json.decode(response.body);

        return Response.ok(
          BaseResult(
            code: 1,
            msg: "登录成功",
            data: {
              'userId': result.id,
              'access_token': map['access_token'],
              'userName': result.username
            },
          ),
        );
      }
    }

    return Response.ok(
      BaseResult(
        code: 1,
        msg: msg,
      ),
    );
  }
}

//class BasicValidator implements
