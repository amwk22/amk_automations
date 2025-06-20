import 'package:automation/modals/Plug.dart';

class EnergyLogs {
  int? id;
  int? powerUsage;
  int? current;
  int? voltage;
  int? energyConsumed;
  String? recordedAt;
  Plug? plugID;
  SystemSettingsID? systemSettingsID;

  EnergyLogs(
      {this.id,
        this.powerUsage,
        this.current,
        this.voltage,
        this.energyConsumed,
        this.recordedAt,
        this.plugID,
        this.systemSettingsID});

  EnergyLogs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    powerUsage = json['powerUsage'];
    current = json['current'];
    voltage = json['voltage'];
    energyConsumed = json['energyConsumed'];
    recordedAt = json['recordedAt'];
    plugID =
    json['plugID'] != null ? new Plug.fromJson(json['plugID']) : null;
    systemSettingsID = json['systemSettingsID'] != null
        ? new SystemSettingsID.fromJson(json['systemSettingsID'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['powerUsage'] = this.powerUsage;
    data['current'] = this.current;
    data['voltage'] = this.voltage;
    data['energyConsumed'] = this.energyConsumed;
    data['recordedAt'] = this.recordedAt;
    if (this.plugID != null) {
      data['plugID'] = this.plugID!.toJson();
    }
    if (this.systemSettingsID != null) {
      data['systemSettingsID'] = this.systemSettingsID!.toJson();
    }
    return data;
  }
}


class SystemSettingsID {
  int? id;
  String? settingKey;
  String? settingValue;
  String? createdAt;
  String? updatedAt;

  SystemSettingsID(
      {this.id,
        this.settingKey,
        this.settingValue,
        this.createdAt,
        this.updatedAt});

  SystemSettingsID.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    settingKey = json['settingKey'];
    settingValue = json['settingValue'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['settingKey'] = this.settingKey;
    data['settingValue'] = this.settingValue;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
