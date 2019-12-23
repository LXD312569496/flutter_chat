/**
 * 用户
 */
class User {
  int id;
  String username;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'];
}
