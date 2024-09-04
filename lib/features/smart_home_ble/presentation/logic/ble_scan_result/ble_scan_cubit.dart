import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'ble_scan_state.dart';

class BleScanCubit extends Cubit<BleScanState> {
  BleScanCubit() : super(BleScanInitial());

  StreamSubscription<List<ScanResult>>? subscription;

  void subscribeScanResult() {
    subscription = FlutterBluePlus.scanResults.listen((results) {
      emit(BleScanLoaded(results));
    });
  }

  Future<void> cancelSubscribeScanResult() async {
    subscription?.cancel();
  }

  Future<void> scanDevice() async {
    try {
      emit(BleScanLoading());
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      emit(BleScanError(e.toString()));
    }
  }

}
