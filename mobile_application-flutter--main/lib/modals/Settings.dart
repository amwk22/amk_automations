class Settings {
  int? id;
  String? settingKey;
  String? settingValue;
  String? createdAt;
  String? updatedAt;
  UserID? userID;

  Settings(
      {this.id,
        this.settingKey,
        this.settingValue,
        this.createdAt,
        this.updatedAt,
        this.userID});

  Settings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    settingKey = json['settingKey'];
    settingValue = json['settingValue'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userID =
    json['userID'] != null ? new UserID.fromJson(json['userID']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['settingKey'] = this.settingKey;
    data['settingValue'] = this.settingValue;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.userID != null) {
      data['userID'] = this.userID!.toJson();
    }
    return data;
  }
}

class UserID {
  int? id;
  String? username;
  String? email;
  String? passwordHash;
  String? role;
  String? createdAt;
  String? updatedAt;

  UserID(
      {this.id,
        this.username,
        this.email,
        this.passwordHash,
        this.role,
        this.createdAt,
        this.updatedAt});

  UserID.fromJson(Map<String, dynamic> json) {
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
