class User {
  int? id;
  String? username;
  String? email;
  String? passwordHash;
  String? role;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
        this.username,
        this.email,
        this.passwordHash,
        this.role,
        this.createdAt,
        this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    passwordHash = json['passwordHash'];
    role = json['role'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['passwordHash'] = this.passwordHash;
    data['role'] = this.role;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
