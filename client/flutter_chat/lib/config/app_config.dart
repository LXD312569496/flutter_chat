/**
 * 保存App配置的信息
 */
class AppConfig {
  bool isBigScreen = false; //是否是大屏幕，比如desktop或者平板

  Enviroment enviroment = Enviroment.DEV;

  String get apiHost {
    switch (enviroment) {
      case Enviroment.LOCAL:
        return "http://127.0.0.1:8888";
      case Enviroment.DEV:
      case Enviroment.PROD:
        return "http://120.77.215.190:8888";
    }
  }
}

/**
 * 环境
 */
enum Enviroment {
  LOCAL, //本地环境
  DEV, //测试环境
  PROD, //生产环境
}
