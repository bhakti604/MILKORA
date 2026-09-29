import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/milk_can.dart';
import '../models/temperature_data.dart';

enum BleStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  sensorLost,
}

class MilkoraBleService extends ChangeNotifier {
  static final MilkoraBleService _instance = MilkoraBleService._internal();
  factory MilkoraBleService() => _instance;
  MilkoraBleService._internal() {
    _initAdapterStateListener();
  }

  // Target BLE Specifications
  static const String targetDeviceName = 'MILKORA-CAN-01';

  // Primary custom UUIDs requested
  static final Guid primaryServiceUuid =
      Guid('12345678-1234-1234-1234-1234567890AB');
  static final Guid primaryTempCharUuid =
      Guid('12345678-1234-1234-1234-1234567890AC');

  // Standard fallback UUIDs (in case standard GATT is used)
  static final Guid fallbackServiceUuid =
      Guid('00001810-0000-1000-8000-00805F9B34FB');
  static final Guid fallbackTempCharUuid =
      Guid('00002A6E-0000-1000-8000-00805F9B34FB');

  // Watchdog timeout duration (10 seconds)
  static const Duration sensorTimeoutDuration = Duration(seconds: 10);

  // State Variables
  BleStatus _status = BleStatus.disconnected;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _tempCharacteristic;

  double? _liveTemperature;
  DateTime? _lastReadingTime;
  String _rawPayload = '';
  String _statusMessage = 'Disconnected';
  String? _errorMessage;

  bool _warningAlertCreated = false;
  bool _criticalAlertCreated = false;
  final List<LiveAlertItem> _alerts = [];
  final List<TempHistoryPoint> _liveHistory = [];

  // Future Sensor Hardware Abstractions (Prepared for ESP32 Lid, Battery, Volume integration)
  bool _isLidHardwareConnected = false;
  bool _hardwareLidClosed = true;
  bool _isBatteryHardwareConnected = false;
  int? _hardwareBatteryPercent;
  bool _isVolumeHardwareConnected = false;
  double? _hardwareVolumeLiters;
  bool _demoMode = false;

  Timer? _watchdogTimer;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _charSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;

  final List<ScanResult> _discoveredDevices = [];

  // Getters
  BleStatus get status => _status;
  bool get isConnected => _status == BleStatus.connected || _status == BleStatus.sensorLost;
  bool get isLive => _status == BleStatus.connected && _liveTemperature != null;
  bool get isSensorLost => _status == BleStatus.sensorLost;
  double? get liveTemperature => _liveTemperature;
  DateTime? get lastReadingTime => _lastReadingTime;
  String get rawPayload => _rawPayload;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  String get deviceName => _connectedDevice?.platformName.isNotEmpty == true
      ? _connectedDevice!.platformName
      : targetDeviceName;
  List<ScanResult> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  List<LiveAlertItem> get alerts => List.unmodifiable(_alerts);
  List<TempHistoryPoint> get liveHistory => List.unmodifiable(_liveHistory);

  // Computed History Statistics from real readings
  double? get highestTemp {
    if (_liveHistory.isEmpty) return null;
    return _liveHistory.map((p) => p.temp).reduce((a, b) => a > b ? a : b);
  }

  double? get lowestTemp {
    if (_liveHistory.isEmpty) return null;
    return _liveHistory.map((p) => p.temp).reduce((a, b) => a < b ? a : b);
  }

  double? get averageTemp {
    if (_liveHistory.isEmpty) return null;
    final sum = _liveHistory.map((p) => p.temp).reduce((a, b) => a + b);
    return double.parse((sum / _liveHistory.length).toStringAsFixed(1));
  }

  // Future Sensor Architecture Getters
  bool get isLidHardwareConnected => _isLidHardwareConnected;
  bool get isLidClosed => _hardwareLidClosed;
  String get lidStatusDisplay => _isLidHardwareConnected
      ? (_hardwareLidClosed ? 'LID CLOSED' : 'LID OPEN')
      : 'Closed (Demo)';

  bool get isBatteryHardwareConnected => _isBatteryHardwareConnected;
  int? get hardwareBatteryPercent => _hardwareBatteryPercent;

  bool get isVolumeHardwareConnected => _isVolumeHardwareConnected;
  double? get hardwareVolumeLiters => _hardwareVolumeLiters;

  bool get isDemoMode => _demoMode;

  void setDemoMode(bool enabled) {
    _demoMode = enabled;
    notifyListeners();
  }

  void updateHardwareLidStatus(bool isClosed) {
    _isLidHardwareConnected = true;
    _hardwareLidClosed = isClosed;
    notifyListeners();
  }

  void updateHardwareBattery(int percent) {
    _isBatteryHardwareConnected = true;
    _hardwareBatteryPercent = percent.clamp(0, 100);
    notifyListeners();
  }

  void updateHardwareVolume(double liters) {
    _isVolumeHardwareConnected = true;
    _hardwareVolumeLiters = liters;
    notifyListeners();
  }

  BluetoothCharacteristic? get tempCharacteristic => _tempCharacteristic;

  TemperatureStatus get currentTempStatus {
    if (_liveTemperature == null) return TemperatureStatus.safe;
    return TemperatureThresholds.evaluate(_liveTemperature!);
  }

  void _initAdapterStateListener() {
    _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state != BluetoothAdapterState.on) {
        if (_status != BleStatus.disconnected) {
          _status = BleStatus.disconnected;
          _statusMessage = 'Bluetooth is turned off';
          _cleanUpConnection();
          notifyListeners();
        }
      }
    });
  }

  /// Request runtime permissions on Android
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      // Modern Android 12+ (API 31+) uses BLUETOOTH_SCAN and BLUETOOTH_CONNECT
      final scanStatus = await Permission.bluetoothScan.request();
      final connectStatus = await Permission.bluetoothConnect.request();

      bool granted = scanStatus.isGranted && connectStatus.isGranted;

      // Legacy Android fallback (API <= 30) where location is required for BLE
      if (!granted) {
        final locStatus = await Permission.locationWhenInUse.request();
        if (locStatus.isGranted) {
          granted = true;
        }
      }

      if (!granted) {
        _errorMessage = 'Bluetooth permission denied. Please allow Nearby Devices / Bluetooth access in Settings.';
        _statusMessage = 'Permission Denied';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return true;
    }
  }

  /// Start scanning for MILKORA ESP32 devices
  Future<void> startScan({Duration timeout = const Duration(seconds: 8)}) async {
    final hasPerm = await requestPermissions();
    if (!hasPerm) return;

    // Check adapter state
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      _errorMessage = 'Please turn on Bluetooth to connect to the milk can.';
      _statusMessage = 'Bluetooth Disabled';
      notifyListeners();
      return;
    }

    _discoveredDevices.clear();
    _errorMessage = null;
    _status = BleStatus.scanning;
    _statusMessage = 'Scanning for MILKORA-CAN-01...';
    notifyListeners();

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          final name = result.device.platformName;
          final advName = result.advertisementData.advName;
          final devName = name.isNotEmpty ? name : advName;

          // STRICT FILTER: Only accept MILKORA-CAN-01 or devices advertising the target service UUID
          final bool isTarget = devName.toUpperCase() == targetDeviceName.toUpperCase() ||
              devName.toUpperCase().contains('MILKORA') ||
              result.advertisementData.serviceUuids.any((u) =>
                  u.toString().toLowerCase().replaceAll('-', '') ==
                  '123456781234123412341234567890ab');

          if (!isTarget) {
            // IGNORE ALL OTHER BLUETOOTH DEVICES (phones, laptops, TVs, headphones, etc.)
            // Never add them to discovered devices to prevent accidental pairing
            continue;
          }

          final existingIndex = _discoveredDevices.indexWhere(
            (r) => r.device.remoteId == result.device.remoteId,
          );
          if (existingIndex >= 0) {
            _discoveredDevices[existingIndex] = result;
          } else {
            _discoveredDevices.add(result);
          }

          // Auto-connect immediately as soon as target MILKORA can is detected
          if (_status == BleStatus.scanning) {
            debugPrint('[BLE DEBUG] Target device match found during scan: $devName. Connecting via BLE GATT directly...');
            _statusMessage = 'Found $devName. Connecting...';
            notifyListeners();
            FlutterBluePlus.stopScan();
            connectToDevice(result.device);
            return;
          }
        }
        notifyListeners();
      });

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: false,
      );

      await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;

      if (_status == BleStatus.scanning) {
        // Auto-connect ONLY if target MILKORA device is found
        final targetIndex = _discoveredDevices.indexWhere(
          (r) {
            final n = r.device.platformName.isNotEmpty
                ? r.device.platformName
                : r.advertisementData.advName;
            return n.toUpperCase() == targetDeviceName.toUpperCase() ||
                n.toUpperCase().contains('MILKORA') ||
                r.advertisementData.serviceUuids.any((u) =>
                    u.toString().toLowerCase().replaceAll('-', '') ==
                    '123456781234123412341234567890ab');
          },
        );

        if (targetIndex >= 0) {
          final targetDeviceResult = _discoveredDevices[targetIndex];
          _statusMessage = 'Found ${targetDeviceResult.device.platformName}';
          notifyListeners();

          // Connect ONLY to the verified MILKORA device
          await connectToDevice(targetDeviceResult.device);
        } else {
          // CRITICAL: NEVER fall back to non-MILKORA devices!
          debugPrint('[BLE DEBUG] MILKORA-CAN-01 not found during scan.');
          _statusMessage = 'MILKORA-CAN-01 not found nearby';
          _errorMessage = 'Ensure the milk can ESP32 is powered on and advertising.';
          _status = BleStatus.disconnected;
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Scan error: $e';
      _statusMessage = 'Scan failed';
      _status = BleStatus.disconnected;
      notifyListeners();
    }
  }

  /// Stop current scan
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    if (_status == BleStatus.scanning) {
      _status = BleStatus.disconnected;
      _statusMessage = 'Scan stopped';
      notifyListeners();
    }
  }

  /// Connect to the specified device (or MILKORA-CAN-01)
  Future<void> connectToDevice(BluetoothDevice device) async {
    await stopScan();

    final devName = device.platformName.isNotEmpty ? device.platformName : targetDeviceName;

    // Safety guard: Reject any non-MILKORA device to avoid triggering foreign device pairing
    final bool isTarget = devName.toUpperCase() == targetDeviceName.toUpperCase() ||
        devName.toUpperCase().contains('MILKORA');

    if (!isTarget && _discoveredDevices.isNotEmpty) {
      final bool isKnownMilkora = _discoveredDevices.any((r) =>
          r.device.remoteId == device.remoteId &&
          (r.advertisementData.advName.toUpperCase().contains('MILKORA') ||
           r.advertisementData.serviceUuids.any((u) =>
               u.toString().toLowerCase().replaceAll('-', '') ==
               '123456781234123412341234567890ab')));
      if (!isKnownMilkora) {
        debugPrint('[BLE DEBUG] Rejected connection to non-MILKORA device: $devName');
        _statusMessage = 'Device is not MILKORA-CAN-01';
        _status = BleStatus.disconnected;
        notifyListeners();
        return;
      }
    }

    _status = BleStatus.connecting;
    _statusMessage = 'Connecting to $devName...';
    _errorMessage = null;
    notifyListeners();

    try {
      _connectedDevice = device;
      debugPrint('[BLE DEBUG] Target device: ${device.platformName} (${device.remoteId})');

      // Monitor connection state
      await _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        debugPrint('[BLE DEBUG] Connection state changed: $state');
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      // Clear any stale bond on Android if present so Android doesn't request a PIN
      try {
        if (Platform.isAndroid && device.prevBondState == BluetoothBondState.bonded) {
          debugPrint('[BLE DEBUG] Removing stale bond to prevent PIN pairing request...');
          await device.removeBond();
        }
      } catch (e) {
        debugPrint('[BLE DEBUG] removeBond notice: $e');
      }

      // Direct BLE GATT connection (autoConnect: false avoids background connection manager)
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
        mtu: null,
      );

      _status = BleStatus.connected;
      _statusMessage = 'Connected ✓. Discovering services...';
      notifyListeners();

      // 1. Discover services
      final services = await device.discoverServices();
      debugPrint('[BLE DEBUG] Discovered ${services.length} services on ${device.platformName}:');
      for (var s in services) {
        debugPrint('[BLE DEBUG]   Service: ${s.uuid}');
        for (var c in s.characteristics) {
          debugPrint('[BLE DEBUG]     Characteristic: ${c.uuid} (read: ${c.properties.read}, notify: ${c.properties.notify})');
        }
      }

      BluetoothCharacteristic? foundChar;

      // Helper to normalize UUID comparison (lowercase, stripped of dashes)
      String cleanUuid(Object u) => u.toString().toLowerCase().replaceAll('-', '').trim();
      const String targetServiceClean = '123456781234123412341234567890ab';
      const String targetCharClean = '123456781234123412341234567890ac';

      // 2 & 3. Find exact service and temperature characteristic
      for (var service in services) {
        final sClean = cleanUuid(service.uuid);
        final bool isTargetService = (sClean == targetServiceClean) || (service.uuid == primaryServiceUuid);
        if (isTargetService) {
          debugPrint('[BLE DEBUG] Matched target service: ${service.uuid}');
        }

        for (var char in service.characteristics) {
          final cClean = cleanUuid(char.uuid);
          final bool isTargetChar = (cClean == targetCharClean) || (char.uuid == primaryTempCharUuid);

          if (isTargetChar) {
            foundChar = char;
            debugPrint('[BLE DEBUG] Matched EXACT characteristic UUID: ${char.uuid} in service: ${service.uuid}');
            break;
          }
        }
        if (foundChar != null) break;
      }

      // Fallback 1: Look in target service for any characteristic with notify or read
      if (foundChar == null) {
        for (var service in services) {
          final sClean = cleanUuid(service.uuid);
          if (sClean == targetServiceClean || service.uuid == primaryServiceUuid) {
            for (var char in service.characteristics) {
              if (char.properties.notify || char.properties.read) {
                foundChar = char;
                debugPrint('[BLE DEBUG] Selected characteristic from target service: ${char.uuid}');
                break;
              }
            }
          }
          if (foundChar != null) break;
        }
      }

      // Fallback 2: Any characteristic with notify across all services
      if (foundChar == null) {
        for (var service in services) {
          for (var char in service.characteristics) {
            if (char.properties.notify) {
              foundChar = char;
              debugPrint('[BLE DEBUG] Fallback characteristic with notify: ${char.uuid}');
              break;
            }
          }
          if (foundChar != null) break;
        }
      }

      if (foundChar == null) {
        throw Exception('Temperature characteristic ($primaryTempCharUuid) not found on device.');
      }

      _tempCharacteristic = foundChar;
      debugPrint('[BLE DEBUG] Target characteristic UUID: ${foundChar.uuid}');

      // 4. Subscribe to notifications using flutter_blue_plus
      // Register onValueReceived listener BEFORE calling setNotifyValue
      await _charSubscription?.cancel();
      _charSubscription = foundChar.onValueReceived.listen((value) {
        debugPrint('[BLE DEBUG] onValueReceived notification: ${value.length} bytes');
        if (value.isNotEmpty) {
          _processIncomingPacket(value);
        }
      });

      // Also listen to lastValueStream as an additional safeguard
      foundChar.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          _processIncomingPacket(value);
        }
      });

      bool notifyResult = false;
      if (foundChar.properties.notify) {
        try {
          notifyResult = await foundChar.setNotifyValue(true);
          debugPrint('[BLE DEBUG] Notify enabled result: $notifyResult');
        } catch (e) {
          debugPrint('[BLE DEBUG] Error enabling notify: $e');
        }
      } else {
        debugPrint('[BLE DEBUG] Characteristic properties.notify is false!');
      }

      // 5. Perform initial READ from the temperature characteristic
      if (foundChar.properties.read) {
        try {
          final initialValue = await foundChar.read();
          debugPrint('[BLE DEBUG] Initial read result: $initialValue');
          if (initialValue.isNotEmpty) {
            _processIncomingPacket(initialValue);
          }
        } catch (e) {
          debugPrint('[BLE DEBUG] Error performing initial read: $e');
        }
      }

      _status = BleStatus.connected;
      _statusMessage = 'Connected ✓';
      _resetWatchdogTimer();
      notifyListeners();
    } catch (e) {
      debugPrint('[BLE DEBUG] Connection error: $e');
      _errorMessage = 'Connection failed: ${e.toString().replaceAll('Exception:', '').trim()}';
      _statusMessage = 'Connection Failed';
      _handleDisconnection();
    }
  }

  /// Parse and process incoming temperature reading
  void _processIncomingPacket(List<int> rawBytes) {
    debugPrint('[BLE DEBUG] Raw received bytes: $rawBytes');
    if (rawBytes.isEmpty) return;

    try {
      // 6. Decode the received bytes as UTF-8 text (e.g. "30.9 C")
      final decodedString = utf8.decode(rawBytes, allowMalformed: true).trim();
      _rawPayload = decodedString;
      debugPrint('[BLE DEBUG] Decoded value: "$decodedString"');

      double? parsedTemp;

      // 7. Parse the numeric temperature (e.g. "30.9 C" -> 30.9)
      final regExp = RegExp(r'[-+]?\d+(?:\.\d+)?');
      final match = regExp.firstMatch(decodedString);
      if (match != null) {
        parsedTemp = double.tryParse(match.group(0)!);
      }

      // Binary fallback: standard 16-bit BLE temperature (in hundredths of °C)
      if (parsedTemp == null && rawBytes.length >= 2) {
        int rawInt = rawBytes[0] | (rawBytes[1] << 8);
        if (rawInt > 32767) rawInt -= 65536; // Signed
        parsedTemp = rawInt / 100.0;
      }

      debugPrint('[BLE DEBUG] Parsed temperature: $parsedTemp');

      // Valid DS18B20 temperature range: -40°C to +85°C
      if (parsedTemp != null && parsedTemp >= -40.0 && parsedTemp <= 85.0) {
        // 8. Immediately update live temperature state
        _liveTemperature = double.parse(parsedTemp.toStringAsFixed(1));
        _lastReadingTime = DateTime.now();
        _status = BleStatus.connected;
        _statusMessage = 'Connected ✓';
        _errorMessage = null;

        // Reset Watchdog Timer
        _resetWatchdogTimer();

        // Evaluate and handle real-time alerts
        _checkAlertTransitions(_liveTemperature!);

        // Add to live history (limit to last 50 points)
        _recordHistoryPoint(_liveTemperature!);

        debugPrint('[BLE DEBUG] Live temperature updated to $_liveTemperature °C -> notifyListeners()');
        notifyListeners();
      } else {
        debugPrint('[BLE DEBUG] Temperature out of valid range (-40 to 85°C): $parsedTemp');
      }
    } catch (e) {
      debugPrint('[BLE DEBUG] Packet parsing error: $e');
    }
  }

  /// Watchdog: alerts if no sensor notification received within 10 seconds
  void _resetWatchdogTimer() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(sensorTimeoutDuration, () {
      if (_status == BleStatus.connected) {
        _status = BleStatus.sensorLost;
        _statusMessage = '⚠️ SENSOR DATA LOST';
        _errorMessage = 'No temperature received for 10s. Checking sensor probe...';
        notifyListeners();
      }
    });
  }

  /// State-transition alert detection: Deduplicates alerts and only re-arms
  /// after returning to SAFE/LOW range as strictly required
  void _checkAlertTransitions(double temp) {
    final status = TemperatureThresholds.evaluate(temp);

    // If safe or low, re-arm alerts so future threshold crossings create new alerts
    if (status == TemperatureStatus.safe || status == TemperatureStatus.low) {
      if (_warningAlertCreated || _criticalAlertCreated) {
        _createAlert(
          temp,
          status,
          title: '✅ MILK TEMPERATURE RESTORED',
          message: 'Temperature returned to safe range (${temp.toStringAsFixed(1)}°C).',
          recommendedAction: 'Normal cold chain conditions restored. Continue regular monitoring.',
          isUrgent: false,
        );
      }
      _warningAlertCreated = false;
      _criticalAlertCreated = false;
      return;
    }

    if (status == TemperatureStatus.warning) {
      if (!_warningAlertCreated) {
        _createAlert(
          temp,
          status,
          title: '⚠️ WARNING: MILK TEMPERATURE RISING',
          message: 'Milk temperature is rising (${temp.toStringAsFixed(1)}°C). Check this can soon.',
          recommendedAction: 'Milk temperature is rising. Check this can soon.',
          isUrgent: false,
        );
        _warningAlertCreated = true;
      }
    } else if (status == TemperatureStatus.critical) {
      if (!_criticalAlertCreated) {
        _createAlert(
          temp,
          status,
          title: '🔴 CRITICAL: MILK TEMPERATURE EXCEEDED',
          message: 'Milk temperature is above safe limit (${temp.toStringAsFixed(1)}°C)! Collect immediately.',
          recommendedAction: 'Milk temperature is above the safe limit. Collect this can immediately.',
          isUrgent: true,
        );
        _criticalAlertCreated = true;
      }
    }
  }

  void _createAlert(
    double temp,
    TemperatureStatus status, {
    required String title,
    required String message,
    required String recommendedAction,
    bool isUrgent = false,
  }) {
    final alert = LiveAlertItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      canId: 'Can M-001',
      title: title,
      message: message,
      recommendedAction: recommendedAction,
      temperature: temp,
      status: status,
      timestamp: DateTime.now(),
      isUrgent: isUrgent,
    );

    _alerts.insert(0, alert);
    if (_alerts.length > 50) {
      _alerts.removeLast();
    }
  }

  void _recordHistoryPoint(double temp) {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    final sec = now.second.toString().padLeft(2, '0');
    final timeStr = '$hour:$min:$sec $period';

    String iconType = 'thermostat';
    if (temp <= TemperatureThresholds.safeMax && temp >= TemperatureThresholds.safeMin) {
      iconType = 'check';
    } else if (temp > TemperatureThresholds.safeMax) {
      iconType = 'north_east';
    }

    _liveHistory.insert(
      0,
      TempHistoryPoint(
        time: timeStr,
        temp: temp,
        iconType: iconType,
        isCurrent: true,
      ),
    );

    // Keep up to 50 history points
    if (_liveHistory.length > 50) {
      _liveHistory.removeLast();
    }
  }

  /// Handle disconnection gracefully
  void _handleDisconnection() {
    _status = BleStatus.disconnected;
    _statusMessage = 'MILK CAN DISCONNECTED';
    _cleanUpConnection();
    notifyListeners();
  }

  /// Disconnect explicitly
  Future<void> disconnect() async {
    _status = BleStatus.disconnected;
    _statusMessage = 'Disconnected';
    _errorMessage = null;
    await _connectedDevice?.disconnect();
    _cleanUpConnection();
    notifyListeners();
  }

  void _cleanUpConnection() {
    _watchdogTimer?.cancel();
    _charSubscription?.cancel();
    _connectionSubscription?.cancel();
    _connectedDevice = null;
    _tempCharacteristic = null;
    _liveTemperature = null;
    _lastReadingTime = null;
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _charSubscription?.cancel();
    _adapterSubscription?.cancel();
    super.dispose();
  }
}
