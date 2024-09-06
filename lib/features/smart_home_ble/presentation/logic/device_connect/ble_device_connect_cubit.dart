import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_home_ble/features/smart_home_ble/domain/model/smart_home_data_model.dart';

part 'ble_device_connect_state.dart';

class BleDeviceConnectCubit extends Cubit<BleDeviceConnectState> {
  BleDeviceConnectCubit() : super(BleDeviceConnectInitial());

  String remoteId = "";
  StreamSubscription<BluetoothConnectionState>? subscription;
  BluetoothCharacteristic? canWriteCharacters;

  Future<void> connectDevice(BluetoothDevice device) async {
    await subscription?.cancel();

    try {
      remoteId = device.remoteId.str;
      emit(BleDeviceConnecting(remoteId));
      await device.connect();
      subscription = device.connectionState.listen((event) async {
        if (event == BluetoothConnectionState.disconnected) {
          remoteId = "";
          canWriteCharacters = null;
          await subscription?.cancel();
          emit(BleDeviceDisconnected());
        }
        if (event == BluetoothConnectionState.connected) {
          emit(BleDeviceConnected(remoteId));
          discoverService(device);
        }
      });
    } catch (e) {
      emit(BleDeviceConnectError(remoteId, e.toString()));
    }
  }

  void discoverService(BluetoothDevice device) async {
    final discoverServices = await device.discoverServices();
    canWriteCharacters = null;
    for (var discoverService in discoverServices) {
      for (var characteristic in discoverService.characteristics) {
        if (characteristic.properties.write) {
          canWriteCharacters = characteristic;
        }
        if (characteristic.properties.notify ||
            characteristic.properties.indicate) {
          try {
            final subscription = characteristic.onValueReceived.listen((event) {
              final model =
                  _convertRawStringToModel(String.fromCharCodes(event));
              if (model != null) {
                emit(BleDeviceReceivedData(remoteId, model));
              }
            });
            device.cancelWhenDisconnected(subscription);
            await characteristic.setNotifyValue(true);
          } catch (_) {}
        }
      }
    }
  }

  SmartHomeDataModel? _convertRawStringToModel(String data) {
    SmartHomeDataModel? model = SmartHomeDataModel();
    final listData = data.split(",");

    for (var element in listData) {
      final keyValue = element.trim().split(":");
      if (keyValue.length == 2) {
        if (keyValue.first == "T") {
          try {
            model.temperature = int.parse(keyValue.last);
          } catch (_) {
            model.temperature = null;
          }
        }

        if (keyValue.first == "H") {
          try {
            model.humidity = int.parse(keyValue.last);
          } catch (_) {
            model.humidity = null;
          }
        }

        if (keyValue.first == "K") {
          try {
            model.distance = int.parse(keyValue.last);
          } catch (_) {
            model.distance = null;
          }
        }
      }
    }

    if (model.temperature == null &&
        model.humidity == null &&
        model.distance == null) {
      return null;
    }

    model.time = DateTime.now();
    return model;
  }

  void write(String cmd) async {
    try {
      await canWriteCharacters?.write(cmd.codeUnits);
    } catch (_) {}
  }
}
