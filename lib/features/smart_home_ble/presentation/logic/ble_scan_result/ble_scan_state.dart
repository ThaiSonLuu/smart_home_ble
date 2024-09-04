part of 'ble_scan_cubit.dart';

sealed class BleScanState extends Equatable {
  const BleScanState();

  @override
  List<Object> get props => [];
}

final class BleScanInitial extends BleScanState {}

final class BleScanLoading extends BleScanState {}

final class BleScanLoaded extends BleScanState {
  const BleScanLoaded(this.devices);

  final List<ScanResult> devices;

  @override
  List<Object> get props => [devices];
}

final class BleScanError extends BleScanState {
  final String error;

  const BleScanError(this.error);

  @override
  List<Object> get props => [error];
}
