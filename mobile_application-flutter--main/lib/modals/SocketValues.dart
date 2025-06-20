class SocketValues {
  String? source;
  String? current;
  String? relay;
  double? currentConsumed;

  SocketValues({this.source, this.current, this.relay, this.currentConsumed});

  SocketValues.fromJson(Map<String, dynamic> json) {
    source = json['source'];
    current = json['current'];
    relay = json['relay'];
    currentConsumed = json['current_consumed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['source'] = this.source;
    data['current'] = this.current;
    data['relay'] = this.relay;
    data['current_consumed'] = this.currentConsumed;
    return data;
  }
}
