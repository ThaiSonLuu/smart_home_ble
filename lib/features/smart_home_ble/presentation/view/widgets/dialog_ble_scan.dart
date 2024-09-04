import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/logic/ble_scan_result/ble_scan_cubit.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/logic/ble_scanning/ble_scanning_cubit.dart';

Future<BluetoothDevice?> showDialogScan(BuildContext context) async {
  return await showDialog<BluetoothDevice?>(
    context: context,
    builder: (context) {
      return const BleScanScreen();
    },
  );
}

class BleScanScreen extends StatefulWidget {
  const BleScanScreen({super.key});

  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  final BleScanningCubit bleScanningCubit = BleScanningCubit();
  final BleScanCubit bleScanCubit = BleScanCubit();

  @override
  void initState() {
    super.initState();
    bleScanningCubit.subscribeScanningStatus();
    bleScanCubit
      ..subscribeScanResult()
      ..scanDevice();
  }

  @override
  void dispose() {
    super.dispose();
    bleScanningCubit.cancelSubscribeScanningStatus();
    bleScanCubit.cancelSubscribeScanResult();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => bleScanningCubit),
        BlocProvider(create: (context) => bleScanCubit),
      ],
      child: const _BleScanScreen(),
    );
  }
}

class _BleScanScreen extends StatelessWidget {
  const _BleScanScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 60,
            width: double.maxFinite,
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Tìm thiết bị",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: BlocBuilder<BleScanningCubit, BleScanningState>(
                      builder: (context, state) {
                        if (state is BleScanningCheck && state.isScanning) {
                          return const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.lightBlue,
                            ),
                          );
                        }

                        return IconButton(
                          onPressed: () {
                            context.read<BleScanCubit>().scanDevice();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            size: 25,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Thoát"),
                    ),
                  ),
                )
              ],
            ),
          ),
          BlocBuilder<BleScanCubit, BleScanState>(
            builder: (context, state) {
              if (state is BleScanLoaded) {
                return Expanded(
                  child: ListView.separated(
                    itemCount: state.devices.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildDeviceItem(context, state.devices[index]),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, ScanResult item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.device.platformName.isNotEmpty ? item.device.platformName : "N/A",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                ),
              ),
              Text(
                item.device.remoteId.str,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          item.rssi.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop(item.device);
          },
          child: const Text("Kết nối"),
        )
      ],
    );
  }
}
