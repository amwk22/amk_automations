class PlugMessage {
  final String source;
  final double current;
  final bool isOn;

  PlugMessage({
    required this.source,
    required this.current,
    required this.isOn,
  });

  factory PlugMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PlugMessage(
      source: json['source'],
      current: (data['current'] as num).toDouble(),
      isOn: data['relay'] == 'ON',
    );
  }
}
