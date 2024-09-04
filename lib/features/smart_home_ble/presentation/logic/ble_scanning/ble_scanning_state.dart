part of 'ble_scanning_cubit.dart';

sealed class BleScanningState extends Equatable {
  const BleScanningState();

  @override
  List<Object> get props => [];
}

final class BleScanningInitial extends BleScanningState {}

final class BleScanningCheck extends BleScanningState {
  const BleScanningCheck(this.isScanning);

  final bool isScanning;

  @override
  List<Object> get props => [isScanning];
}
