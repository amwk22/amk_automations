class PendingRequests {
  int? id;
  Plug? plug;
  String? action;
  String? status;
  String? createdAt;

  PendingRequests(
      {this.id, this.plug, this.action, this.status, this.createdAt});

  PendingRequests.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    plug = json['plug'] != null ? new Plug.fromJson(json['plug']) : null;
    action = json['action'];
    status = json['status'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.plug != null) {
      data['plug'] = this.plug!.toJson();
    }
    data['action'] = this.action;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    return data;
  }
}

class Plug {
  int? id;
  String? zigbeeAddress;
  String? name;
  bool? status;
  int? estimatedAmps;
  String? createdAt;
  String? updatedAt;

  Plug(
      {this.id,
        this.zigbeeAddress,
        this.name,
        this.status,
        this.estimatedAmps,
        this.createdAt,
        this.updatedAt});

  Plug.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    zigbeeAddress = json['zigbeeAddress'];
    name = json['name'];
    status = json['status'];
    estimatedAmps = json['estimatedAmps'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
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
    return data;
  }
}
