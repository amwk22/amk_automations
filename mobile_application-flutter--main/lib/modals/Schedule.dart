class Schedule {
  int? id;
  String? onTime;
  String? offTime;
  List<String>? days;
  bool? isActive;
  String? createdAt;

  Schedule(
      {this.id,
        this.onTime,
        this.offTime,
        this.days,
        this.isActive,
        this.createdAt});

  Schedule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    onTime = json['onTime'];
    offTime = json['offTime'];
    days = json['days'].cast<String>();
    isActive = json['isActive'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['onTime'] = this.onTime;
    data['offTime'] = this.offTime;
    data['days'] = this.days;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
