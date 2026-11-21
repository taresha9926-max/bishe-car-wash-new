class SentinelConfig {
  final String status; // 'online' or 'offline'
  final int batteryLevel;
  final String targetCbeAccount;
  final String targetCbeName;
  final String targetTelebirrPhone;
  final String targetTelebirrName;
  final String securityMode; // 'flexible' (Policy 1) or 'strict' (Policy 2)
  final String secretToken;
  final DateTime? lastHeartbeat;

  const SentinelConfig({
    this.status = 'online',
    this.batteryLevel = 100,
    this.targetCbeAccount = '1000542824388',
    this.targetCbeName = 'Tariku G/tsadik G/silase',
    this.targetTelebirrPhone = '0962274450',
    this.targetTelebirrName = 'Tariku Gebretsadike',
    this.securityMode = 'flexible',
    this.secretToken = 'bishe_sentinel_sec_2026_x89',
    this.lastHeartbeat,
  });

  bool get isStrict => securityMode == 'strict';
  bool get isFlexible => securityMode == 'flexible';

  bool get isOnline {
    if (status != 'online') return false;
    if (lastHeartbeat == null) return true;
    return DateTime.now().difference(lastHeartbeat!).inMinutes < 30;
  }

  factory SentinelConfig.fromJson(Map<String, dynamic> json) {
    return SentinelConfig(
      status: json['sentinel_status']?.toString() ?? 'online',
      batteryLevel: int.tryParse(json['battery_level']?.toString() ?? '100') ?? 100,
      targetCbeAccount: json['target_cbe_account']?.toString() ?? '1000542824388',
      targetCbeName: json['target_cbe_name']?.toString() ?? 'Tariku G/tsadik G/silase',
      targetTelebirrPhone: json['target_telebirr_phone']?.toString() ?? '0962274450',
      targetTelebirrName: json['target_telebirr_name']?.toString() ?? 'Tariku Gebretsadike',
      securityMode: json['security_mode']?.toString() ?? 'flexible',
      secretToken: json['secret_token']?.toString() ?? 'bishe_sentinel_sec_2026_x89',
      lastHeartbeat: json['last_heartbeat'] != null
          ? DateTime.tryParse(json['last_heartbeat'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentinel_status': status,
      'battery_level': batteryLevel,
      'target_cbe_account': targetCbeAccount,
      'target_cbe_name': targetCbeName,
      'target_telebirr_phone': targetTelebirrPhone,
      'target_telebirr_name': targetTelebirrName,
      'security_mode': securityMode,
      'secret_token': secretToken,
      'last_heartbeat': lastHeartbeat?.toIso8601String(),
    };
  }
}
