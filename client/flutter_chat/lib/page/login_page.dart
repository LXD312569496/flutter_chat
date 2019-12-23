import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/config/app_config.dart';
import 'package:flutter_chat/page/chat_list_page.dart';
import 'package:get_it/get_it.dart';
import 'package:oktoast/oktoast.dart';

/**
 * 登录页面
 */
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username_controller = TextEditingController(text: "");
  TextEditingController password_controller = TextEditingController(text: "");

  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(hintText: "用户名"),
              controller: username_controller,
            ),
            TextFormField(
              controller: password_controller,
              decoration: InputDecoration(hintText: "密码"),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text("登录"),
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  onPressed: () {
                    register();
                  },
                  child: Text("注册"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void login() async {
    Dio dio = Dio(BaseOptions(baseUrl: GetIt.instance<AppConfig>().apiHost));

    Response<Map<String, dynamic>> response =
        await dio.post<Map<String, dynamic>>(
      "/login",
      data: {
        'username': username_controller.text.toString(),
        'password': password_controller.text.toString(),
      },
    );

    print("登录结果:$response");
    if (response != null &&
        response.data != null &&
        response.data['code'] == 1 &&
        response.data['data']['access_token'] != null) {
      //登录成功
      String token = response.data['data']['access_token'];
      int fromUserId = response.data['data']['userId'];
      String userName = response.data['data']['userName'];

      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ChatListPage(
          token: token,
          fromUserId: fromUserId,
          userName: userName,
        );
      }));
    }
  }

  void register() async {
    Dio dio = Dio(BaseOptions(baseUrl: GetIt.instance<AppConfig>().apiHost));

    Response<Map<String, dynamic>> response =
        await dio.post<Map<String, dynamic>>(
      "/register",
      data: {
        'username': username_controller.text.toString(),
        'password': password_controller.text.toString(),
      },
    );

    print("注册结果:$response");
    if (response != null &&
        response.data != null &&
        response.data['code'] == 1) {
      showToast(response.data['msg']);
    } else {
      showToast("注册失败");
    }
  }
}
