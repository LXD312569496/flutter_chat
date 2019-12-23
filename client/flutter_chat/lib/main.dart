import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/page/login_page.dart';
import 'package:flutter_chat/config/app_config.dart';
import 'package:flutter_chat/util/socket_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:ui';

void main() {
  GetIt.instance.registerSingleton<SocketManager>(SocketManager());
  GetIt.instance.registerSingleton<AppConfig>(AppConfig());
  AppConfig appConfig = GetIt.instance<AppConfig>();
  appConfig.enviroment = Enviroment.PROD;
  if (window.physicalSize.aspectRatio > 1) {
    //说明是横屏或者大屏幕
    appConfig.isBigScreen = true;
  } else {
    appConfig.isBigScreen = false;
  }
  runApp(MyApp());
}

//设置代码，能够同时在桌面和app端运行
void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  } else {
    targetPlatform = TargetPlatform.fuchsia;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        supportedLocales: [
          const Locale('en', ''),
          const Locale('zh', ''),
        ],
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SafeArea(
          child: LoginPage(),
        ),
      ),
    );
  }
}
