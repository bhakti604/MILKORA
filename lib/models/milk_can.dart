enum CanStatus { safe, checkSoon, collectNow }

class TempHistoryPoint {
  final String time;
  final double temp;
  final String iconType; // check, north_east, thermostat, east
  final bool isCurrent;

  TempHistoryPoint({
    required this.time,
    required this.temp,
    required this.iconType,
    this.isCurrent = false,
  });

  factory TempHistoryPoint.fromJson(Map<String, dynamic> json) {
    return TempHistoryPoint(
      time: json['time'] as String,
      temp: (json['temp'] as num).toDouble(),
      iconType: json['iconType'] as String,
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temp': temp,
      'iconType': iconType,
      'isCurrent': isCurrent,
    };
  }
}

class MilkCan {
  final String id;
  final String name;
  final String batchName;
  final double temperature;
  final double targetTemp;
  final double tempLimit;
  final double volumeLiters;
  final int lidOpenedCount;
  final bool isLidClosed;
  final int batteryLevel;
  final String batteryStatus;
  final CanStatus status;
  final String safeTimeLeft;
  final String statusText;
  final String farmerName;
  final String farmerId;
  final String bayLocation;
  final String statusNote;
  final List<TempHistoryPoint> history;

  MilkCan({
    required this.id,
    required this.name,
    required this.batchName,
    required this.temperature,
    this.targetTemp = 4.0,
    this.tempLimit = 10.0,
    required this.volumeLiters,
    required this.lidOpenedCount,
    this.isLidClosed = true,
    required this.batteryLevel,
    required this.batteryStatus,
    required this.status,
    required this.safeTimeLeft,
    required this.statusText,
    required this.farmerName,
    required this.farmerId,
    required this.bayLocation,
    required this.statusNote,
    required this.history,
  });

  factory MilkCan.fromJson(Map<String, dynamic> json) {
    return MilkCan(
      id: json['id'] as String,
      name: json['name'] as String,
      batchName: json['batchName'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      targetTemp: (json['targetTemp'] as num?)?.toDouble() ?? 4.0,
      tempLimit: (json['tempLimit'] as num?)?.toDouble() ?? 10.0,
      volumeLiters: (json['volumeLiters'] as num).toDouble(),
      lidOpenedCount: json['lidOpenedCount'] as int,
      isLidClosed: json['isLidClosed'] as bool? ?? true,
      batteryLevel: json['batteryLevel'] as int,
      batteryStatus: json['batteryStatus'] as String,
      status: CanStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => CanStatus.safe,
      ),
      safeTimeLeft: json['safeTimeLeft'] as String,
      statusText: json['statusText'] as String,
      farmerName: json['farmerName'] as String,
      farmerId: json['farmerId'] as String,
      bayLocation: json['bayLocation'] as String,
      statusNote: json['statusNote'] as String,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => TempHistoryPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'batchName': batchName,
      'temperature': temperature,
      'targetTemp': targetTemp,
      'tempLimit': tempLimit,
      'volumeLiters': volumeLiters,
      'lidOpenedCount': lidOpenedCount,
      'isLidClosed': isLidClosed,
      'batteryLevel': batteryLevel,
      'batteryStatus': batteryStatus,
      'status': status.toString(),
      'safeTimeLeft': safeTimeLeft,
      'statusText': statusText,
      'farmerName': farmerName,
      'farmerId': farmerId,
      'bayLocation': bayLocation,
      'statusNote': statusNote,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }

  static List<MilkCan> get mockCans => [
        MilkCan(
          id: 'M-001',
          name: 'Can M-001',
          batchName: 'Morning Chilling Batch',
          temperature: 6.3,
          volumeLiters: 27.8,
          lidOpenedCount: 2,
          batteryLevel: 86,
          batteryStatus: 'Strong',
          status: CanStatus.safe,
          safeTimeLeft: '4 Hours 18 Minutes',
          statusText: 'SAFE',
          farmerName: 'Morning Shift Worker',
          farmerId: '#1001',
          bayLocation: 'Bay 1',
          statusNote: 'Milk is still cold and well preserved.',
          history: [
            TempHistoryPoint(time: '8:00 AM', temp: 6.0, iconType: 'check'),
            TempHistoryPoint(time: '9:00 AM', temp: 6.2, iconType: 'north_east'),
            TempHistoryPoint(time: '10:00 AM', temp: 6.3, iconType: 'thermostat', isCurrent: true),
            TempHistoryPoint(time: '11:00 AM (Est.)', temp: 6.5, iconType: 'east'),
          ],
        ),
        MilkCan(
          id: 'M-002',
          name: 'Can M-002',
          batchName: 'Morning Chilling Batch',
          temperature: 7.2,
          volumeLiters: 31.2,
          lidOpenedCount: 1,
          batteryLevel: 92,
          batteryStatus: 'Strong',
          status: CanStatus.safe,
          safeTimeLeft: '3h 45m',
          statusText: 'SAFE',
          farmerName: 'Suresh Kumar',
          farmerId: '#2041',
          bayLocation: 'Bay 1',
          statusNote: 'Chilling optimal, stable baseline.',
          history: [
            TempHistoryPoint(time: '8:00 AM', temp: 6.8, iconType: 'check'),
            TempHistoryPoint(time: '9:00 AM', temp: 7.0, iconType: 'north_east'),
            TempHistoryPoint(time: '10:00 AM', temp: 7.2, iconType: 'thermostat', isCurrent: true),
          ],
        ),
        MilkCan(
          id: 'M-003',
          name: 'Can M-003',
          batchName: 'Mid-Morning Transfer',
          temperature: 8.4,
          volumeLiters: 24.5,
          lidOpenedCount: 4,
          batteryLevel: 64,
          batteryStatus: 'Moderate',
          status: CanStatus.checkSoon,
          safeTimeLeft: '1h 10m',
          statusText: 'CHECK SOON',
          farmerName: 'Vikram Singh',
          farmerId: '#3104',
          bayLocation: 'Bay 3',
          statusNote: 'Temperature is getting high.',
          history: [
            TempHistoryPoint(time: '8:00 AM', temp: 6.5, iconType: 'check'),
            TempHistoryPoint(time: '9:00 AM', temp: 7.6, iconType: 'north_east'),
            TempHistoryPoint(time: '10:00 AM', temp: 8.4, iconType: 'thermostat', isCurrent: true),
          ],
        ),
        MilkCan(
          id: 'M-004',
          name: 'Can M-004',
          batchName: 'Direct Farm Intake',
          temperature: 9.6,
          volumeLiters: 29.0,
          lidOpenedCount: 6,
          batteryLevel: 45,
          batteryStatus: 'Fair',
          status: CanStatus.collectNow,
          safeTimeLeft: '15 Minutes',
          statusText: 'COLLECT NOW',
          farmerName: 'Ramesh Patel',
          farmerId: '#4092',
          bayLocation: 'Bay 2',
          statusNote: 'Milk may become unsafe. Please collect this can first.',
          history: [
            TempHistoryPoint(time: '9:00 AM', temp: 7.2, iconType: 'check'),
            TempHistoryPoint(time: '9:30 AM', temp: 8.5, iconType: 'north_east'),
            TempHistoryPoint(time: '9:38 AM', temp: 9.6, iconType: 'thermostat', isCurrent: true),
          ],
        ),
      ];
}
