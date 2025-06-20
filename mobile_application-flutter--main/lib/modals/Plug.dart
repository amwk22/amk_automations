class Plug {
  int? id;
  String? zigbeeAddress;
  String? name;
  bool? status;
  var estimatedAmps;
  String? createdAt;
  String? updatedAt;
  Users? users;

  Plug(
      {this.id,
        this.zigbeeAddress,
        this.name,
        this.status,
        this.estimatedAmps,
        this.createdAt,
        this.updatedAt,
        this.users});

  Plug.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    zigbeeAddress = json['zigbeeAddress'];
    name = json['name'];
    status = json['status'];
    estimatedAmps = json['estimatedAmps'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    users = json['users'] != null ? new Users.fromJson(json['users']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['zigbeeAddress'] = this.zigbeeAddress;
    data['name'] = this.name;
    data['status'] = this.status;
    data['estimatedAmps'] = this.estimatedAmps;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.users != null) {
      data['users'] = this.users!.toJson();
    }
    return data;
  }
}

class Users {
  int? id;
  String? username;
  String? email;
  String? passwordHash;
  String? role;
  String? createdAt;
  String? updatedAt;

  Users(
      {this.id,
        this.username,
        this.email,
        this.passwordHash,
        this.role,
        this.createdAt,
        this.updatedAt});

  Users.fromJson(Map<String, dynamic> json) {
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
