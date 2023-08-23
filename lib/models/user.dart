class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? token;

  User({this.id, this.name, this.email, this.phone, this.role, this.token});

  // function to convert json data to user model
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['user']['id'],
        name: json['user']['name'],
        email: json['user']['email'],
        phone: json['user']['phone'],
        role: json['role'],
        token: json['token']);
  }
}
