part of 'ble_support_cubit.dart';

sealed class BleSupportState extends Equatable {
  const BleSupportState();

  @override
  List<Object> get props => [];
}

final class BleSupportInitial extends BleSupportState {}

final class BleSupportLoading extends BleSupportState {}

final class BleSupportNotSupport extends BleSupportState {}

final class BleSupportTurnOn extends BleSupportState {}

final class BleSupportTurnOff extends BleSupportState {}

