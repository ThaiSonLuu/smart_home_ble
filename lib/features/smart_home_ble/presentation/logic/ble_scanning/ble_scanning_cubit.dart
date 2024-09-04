import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'ble_scanning_state.dart';

class BleScanningCubit extends Cubit<BleScanningState> {
  BleScanningCubit() : super(BleScanningInitial());

  StreamSubscription<bool>? subscription;
  
  void subscribeScanningStatus() {
    subscription = FlutterBluePlus.isScanning.listen((event) {
      emit(BleScanningCheck(event));
    });
  }

  Future<void> cancelSubscribeScanningStatus() async {
    await subscription?.cancel();
  }

}
