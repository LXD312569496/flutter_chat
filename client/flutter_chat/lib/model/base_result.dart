
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

//  BaseResult.fromJson(Map<String, dynamic> json):
//      code=json['code'],
//  msg=json['msg'],
//  data=

}
