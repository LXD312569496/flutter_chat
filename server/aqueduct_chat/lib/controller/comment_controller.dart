import 'package:aqueduct_chat/aqueduct_chat.dart';

/**
 * 评论接口
 */
class CommentController extends ResourceController{


  @Operation.get()
  Future<Response> getAllComment()async{

    return Response.ok("获取所有评论");
  }
}