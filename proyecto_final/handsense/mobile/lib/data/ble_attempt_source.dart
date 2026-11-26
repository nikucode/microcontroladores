import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import 'attempt.dart';
import 'handsense_protocol.dart';

/// Fuente física BLE. Descubre únicamente dispositivos que anuncian el
/// servicio HandSense y convierte notificaciones GATT validadas en intentos.
class BleAttemptSource implements AttemptSource, DeviceControls {
  BleAttemptSource({FlutterReactiveBle? ble})
    : _ble = ble ?? FlutterReactiveBle();

  final FlutterReactiveBle _ble;
  final _attempts = StreamController<Attempt>.broadcast(sync: true);
  final _states = StreamController<HandSenseConnectionState>.broadcast(
    sync: true,
  );
  final _telemetry = StreamController<DeviceTelemetry>.broadcast(sync: true);
  final Set<int> _seenSequences = {};
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _eventSubscription;
  Completer<bool>? _pendingCommand;
  String? _pendingCommandName;
  String? _deviceId;
  bool _disposed = false;
  bool _cancelRequested = false;

  HandSenseConnectionState _state = const HandSenseConnectionState(
    DeviceConnectionPhase.idle,
    'Listo para buscar HandSense.',
  );

  @override
  Stream<Attempt> get events => _attempts.stream;
  @override
  String get label => 'HandSense BLE';
  @override
  bool get isDemo => false;
  @override
  Stream<HandSenseConnectionState> get connectionStates => _states.stream;
  @override
  Stream<DeviceTelemetry> get telemetry => _telemetry.stream;
  @override
  HandSenseConnectionState get connectionState => _state;

  void _setState(
    DeviceConnectionPhase phase,
    String message, {
    String? deviceName,
  }) {
    if (_disposed) return;
    _state = HandSenseConnectionState(
      phase,
      message,
      deviceName: deviceName ?? _state.deviceName,
    );
    _states.add(_state);
  }

  Future<bool> _requestPermissions() async {
    _setState(
      DeviceConnectionPhase.requestingPermission,
      'Solicitando permiso para buscar dispositivos cercanos…',
    );
    final result = await <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    final modern =
        result[Permission.bluetoothScan]?.isGranted == true &&
        result[Permission.bluetoothConnect]?.isGranted == true;
    final legacy = result[Permission.locationWhenInUse]?.isGranted == true;
    return modern || legacy;
  }

  @override
  Future<void> connect() async {
    await disconnect(announce: false);
    _cancelRequested = false;
    try {
      if (!await _requestPermissions()) {
        _setState(
          DeviceConnectionPhase.error,
          'Falta permiso de Bluetooth. Puedes habilitarlo en Ajustes de Android.',
        );
        return;
      }
      if (_ble.status != BleStatus.ready) {
        final technicalStatus = _ble.status.name;
        _setState(
          DeviceConnectionPhase.error,
          'Bluetooth todavía no está disponible. Comprueba que esté encendido y concede el permiso de dispositivos cercanos. Estado técnico: $technicalStatus.',
        );
        return;
      }

      _setState(
        DeviceConnectionPhase.scanning,
        'Buscando un dispositivo HandSense durante 10 segundos…',
      );
      final found = Completer<DiscoveredDevice>();
      final service = Uuid.parse(HandSenseGatt.service);
      _scanSubscription = _ble
          .scanForDevices(withServices: [service], scanMode: ScanMode.balanced)
          .listen(
            (device) {
              if (!found.isCompleted &&
                  (device.name.startsWith(HandSenseGatt.deviceName) ||
                      device.serviceUuids.contains(service))) {
                found.complete(device);
              }
            },
            onError: (Object error) {
              if (!found.isCompleted) found.completeError(error);
            },
          );
      final device = await found.future.timeout(const Duration(seconds: 10));
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _deviceId = device.id;
      _setState(
        DeviceConnectionPhase.connecting,
        'Conectando con ${device.name.isEmpty ? 'HandSense' : device.name}…',
        deviceName: device.name.isEmpty ? 'HandSense' : device.name,
      );
      await _connectTo(device);
    } on TimeoutException {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      if (!_cancelRequested) {
        _setState(
          DeviceConnectionPhase.error,
          'No se encontró HandSense. Verifica que el ESP32 esté encendido y anunciando BLE.',
        );
      }
    } catch (error) {
      if (!_cancelRequested) {
        _setState(
          DeviceConnectionPhase.error,
          'No fue posible conectar: $error',
        );
      }
    }
  }

  Future<void> _connectTo(DiscoveredDevice device) async {
    final connected = Completer<void>();
    _connectionSubscription = _ble
        .connectToDevice(
          id: device.id,
          servicesWithCharacteristicsToDiscover: {
            Uuid.parse(HandSenseGatt.service): [
              Uuid.parse(HandSenseGatt.events),
              Uuid.parse(HandSenseGatt.control),
            ],
          },
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen(
          (update) async {
            switch (update.connectionState) {
              case DeviceConnectionState.connecting:
                break;
              case DeviceConnectionState.connected:
                await _listenForEvents(device.id);
                _setState(
                  DeviceConnectionPhase.connected,
                  'Conectado. Esperando eventos reales del ESP32.',
                  deviceName: device.name.isEmpty ? 'HandSense' : device.name,
                );
                if (!connected.isCompleted) connected.complete();
              case DeviceConnectionState.disconnecting:
                break;
              case DeviceConnectionState.disconnected:
                _setState(
                  DeviceConnectionPhase.disconnected,
                  'HandSense se desconectó. Puedes volver a buscarlo.',
                );
                if (!connected.isCompleted) {
                  connected.completeError(
                    StateError(
                      'El dispositivo se desconectó antes de estar listo.',
                    ),
                  );
                }
            }
          },
          onError: (Object error) {
            _setState(DeviceConnectionPhase.error, 'Error BLE: $error');
            if (!connected.isCompleted) connected.completeError(error);
          },
        );
    await connected.future.timeout(const Duration(seconds: 12));
  }

  Future<void> _listenForEvents(String deviceId) async {
    await _eventSubscription?.cancel();
    final characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse(HandSenseGatt.service),
      characteristicId: Uuid.parse(HandSenseGatt.events),
      deviceId: deviceId,
    );
    _eventSubscription = _ble
        .subscribeToCharacteristic(characteristic)
        .listen(
          _handleFrame,
          onError: (Object error) => _setState(
            DeviceConnectionPhase.error,
            'Error recibiendo eventos: $error',
          ),
        );
  }

  void _handleFrame(List<int> bytes) {
    final frame = parseHandSenseFrame(bytes);
    switch (frame) {
      case AttemptFrame(:final sequence, :final outcome):
        if (_seenSequences.add(sequence)) {
          _attempts.add(Attempt(sequence, outcome));
        }
      case AcknowledgementFrame(:final command, :final ok):
        final pending = _pendingCommand;
        if (command == _pendingCommandName &&
            pending != null &&
            !pending.isCompleted) {
          pending.complete(ok);
        }
      case TelemetryFrame(
        :final flexionPercent,
        :final contactPercent,
        :final phase,
      ):
        _telemetry.add(DeviceTelemetry(flexionPercent, contactPercent, phase));
      case null:
        break;
    }
  }

  @override
  Future<bool> ping() async {
    return _sendCommand('PING');
  }

  @override
  Future<bool> resetDeviceSession() async {
    // RESET es idempotente: si el ACK se pierde, un unico reintento deja la
    // sesion igualmente reiniciada sin duplicar intentos ni mediciones.
    var acknowledged = await _sendCommand('RESET');
    if (!acknowledged && _state.connected) {
      acknowledged = await _sendCommand('RESET');
    }
    if (acknowledged) _seenSequences.clear();
    return acknowledged;
  }

  Future<bool> _sendCommand(String name) async {
    final deviceId = _deviceId;
    if (deviceId == null || !_state.connected) return false;
    if (_pendingCommand != null) return false;
    final pending = Completer<bool>();
    _pendingCommand = pending;
    _pendingCommandName = name;
    final characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse(HandSenseGatt.service),
      characteristicId: Uuid.parse(HandSenseGatt.control),
      deviceId: deviceId,
    );
    try {
      await _ble.writeCharacteristicWithResponse(
        characteristic,
        value: HandSenseGatt.command(name),
      );
      return await pending.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    } finally {
      if (identical(_pendingCommand, pending)) {
        _pendingCommand = null;
        _pendingCommandName = null;
      }
    }
  }

  @override
  Future<void> disconnect({bool announce = true}) async {
    _cancelRequested = true;
    await _scanSubscription?.cancel();
    await _eventSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _scanSubscription = null;
    _eventSubscription = null;
    _connectionSubscription = null;
    _deviceId = null;
    _seenSequences.clear();
    final pending = _pendingCommand;
    if (pending != null && !pending.isCompleted) pending.complete(false);
    _pendingCommand = null;
    _pendingCommandName = null;
    if (announce && !_disposed) {
      _setState(
        DeviceConnectionPhase.disconnected,
        'Dispositivo desconectado.',
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _scanSubscription?.cancel();
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    final pending = _pendingCommand;
    if (pending != null && !pending.isCompleted) pending.complete(false);
    _attempts.close();
    _states.close();
    _telemetry.close();
  }
}
