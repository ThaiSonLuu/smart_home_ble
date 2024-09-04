import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

part 'ble_support_state.dart';

class BleSupportCubit extends Cubit<BleSupportState> {
  BleSupportCubit() : super(BleSupportInitial());

  StreamSubscription<BluetoothAdapterState>? subscription;
  
  Future<void> checkAvailable() async {
    await requestPermission();
    try {
      emit(BleSupportLoading());
      final isSupport = await FlutterBluePlus.isSupported;
      if (isSupport) {
        subscribeAdapterState();
      } else {
        emit(BleSupportNotSupport());
      }
    } catch (_) {
      emit(BleSupportNotSupport());
    }
  }

  Future<void> requestPermission() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();
  }

  void subscribeAdapterState() {
    subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
      if(state == BluetoothAdapterState.on) {
        emit(BleSupportTurnOn());
      } else {
        emit(BleSupportTurnOff());
      }
    });
  }

  Future<void> turnOn() async {
    await FlutterBluePlus.turnOn();
  }

  Future<void> cancelSubscribeAdapterState() async {
    await subscription?.cancel();
  }
  
}
