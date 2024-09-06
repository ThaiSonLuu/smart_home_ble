part of 'ble_device_connect_cubit.dart';

sealed class BleDeviceConnectState extends Equatable {
  const BleDeviceConnectState();

  @override
  List<Object?> get props => [];
}

final class BleDeviceConnectInitial extends BleDeviceConnectState {}

final class BleDeviceConnecting extends BleDeviceConnectState {
  const BleDeviceConnecting(this.remoteId);

  final String remoteId;

  @override
  List<Object?> get props => [remoteId];
}

final class BleDeviceConnectError extends BleDeviceConnectState {
  const BleDeviceConnectError(this.remoteId, this.error);

  final String remoteId;
  final String error;

  @override
  List<Object?> get props => [remoteId, error];
}

final class BleDeviceConnected extends BleDeviceConnectState {
  const BleDeviceConnected(this.remoteId);

  final String remoteId;

  @override
  List<Object?> get props => [remoteId];
}

final class BleDeviceReceivedData extends BleDeviceConnectState {
  const BleDeviceReceivedData(this.remoteId, this.model);

  final String remoteId;
  final SmartHomeDataModel? model;

  @override
  List<Object?> get props => [remoteId, model];
}

final class BleDeviceDisconnected extends BleDeviceConnectState {}


