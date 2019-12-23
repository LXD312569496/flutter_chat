import 'package:aqueduct/managed_auth.dart';
import 'package:aqueduct_chat/aqueduct_chat.dart';

/**
 * 用户表
 */
class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {


  @Serialize(input: true, output: false)
  String password;//密码的md5值

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'username': username,
      'password': password,
      'tokens':tokens
    };
  }
}

class _User extends ResourceOwnerTableDefinition {

//  @Column()
//  String avatar_url;//用户头像

}
