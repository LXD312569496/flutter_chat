/**
 * 响应结果的基类
 */
class BaseResult<T> {
  int code; //返回码
  String msg; //信息
  T data;

  BaseResult({this.code, this.msg, this.data}); //数据

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data,
    };
  }
}

///**
// * 一些错误码
// */
//enum BaseResultCode{
//  REGISTER_FAILED_USER_EXIT=1;//注册失败
//
//}
