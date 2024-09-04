import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
import 'package:smart_home_ble/features/smart_home_ble/data/local/share_pref_manager.dart';
import 'package:smart_home_ble/features/smart_home_ble/domain/model/smart_home_data_model.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/logic/ble_support/ble_support_cubit.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/logic/device_connect/ble_device_connect_cubit.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/view/widgets/dialog_ble_scan.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/view/widgets/dialog_change_cmd.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/view/widgets/item_control_action.dart';
import 'package:smart_home_ble/gen/assets.gen.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BleSupportCubit bleSupportCubit = BleSupportCubit();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    super.dispose();
    bleSupportCubit.cancelSubscribeAdapterState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => bleSupportCubit..checkAvailable()),
        BlocProvider(create: (context) => BleDeviceConnectCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Smart Home",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          backgroundColor: Colors.lightBlue,
        ),
        body: _BluetoothContent(),
      ),
    );
  }
}

class _BluetoothContent extends StatefulWidget {
  @override
  State<_BluetoothContent> createState() => _BluetoothContentState();
}

class _BluetoothContentState extends State<_BluetoothContent> {
  List<String> controlMode = ["Bluetooth", "Touch", "Sensor"];
  String currentMode = "Bluetooth";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: BlocBuilder<BleSupportCubit, BleSupportState>(
            builder: (blocContext, state) {
              if (state is BleSupportNotSupport) {
                return const Center(
                    child: Text("Thiết bị không hỗ trợ Bluetooth"));
              }

              if (state is BleSupportTurnOff) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Bluetooth chưa được bật"),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BleSupportCubit>().turnOn();
                      },
                      child: const Text("Bật ngay"),
                    )
                  ],
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildScanView(context),
                    _buildInformation(),
                    const SizedBox(height: 10),
                    _buildControlMode(),
                    const SizedBox(height: 10),
                    _buildControlAction(),
                  ],
                ),
              );
            },
          )),
    );
  }

  Widget _buildScanView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: BlocBuilder<BleDeviceConnectCubit, BleDeviceConnectState>(
              builder: (context, state) {
                if (state is BleDeviceConnecting) {
                  return Text("Đang kết nối với ${state.remoteId}");
                }

                if (state is BleDeviceConnectError) {
                  return Text(
                    "Kết nối với ${state.remoteId} lỗi: ${state.error}",
                    maxLines: 3,
                  );
                }

                if (state is BleDeviceConnected) {
                  return Text("Kết nối thành công: ${state.remoteId}");
                }

                if (state is BleDeviceReceivedData) {
                  return Text("Nhận dữ liệu từ: ${state.remoteId}");
                }

                return const Text("Chưa kết nối");
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final device = await showDialogScan(context);
              if (context.mounted && device != null) {
                context.read<BleDeviceConnectCubit>().connectDevice(device);
              }
            },
            child: const Text("Quét"),
          )
        ],
      ),
    );
  }

  Widget _buildInformation() {
    Widget buildInfoItem(String path, String text) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              path,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      );
    }

    return BlocBuilder<BleDeviceConnectCubit, BleDeviceConnectState>(
      builder: (context, state) {
        SmartHomeDataModel? model;

        if (state is BleDeviceReceivedData) {
          model = state.model;
        }

        return Column(
          children: [
            const Divider(),
            buildInfoItem(Assets.images.temperature.path,
                "Nhiệt độ: ${model?.temperature ?? "-"}°C"),
            const Divider(),
            buildInfoItem(Assets.images.humidity.path,
                "Độ ẩm: ${model?.humidity ?? "-"}%"),
            const Divider(),
            buildInfoItem(Assets.images.ruler.path,
                "Khoảng cách vật thể: ${model?.distance ?? "-"} cm"),
            const Divider(),
            buildInfoItem(Assets.images.time.path,
                "Thời gian: ${model?.time != null ? DateFormat("HH:mm:ss dd/MM/yyyy").format(model!.time!) : "-"}"),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildControlMode() {
    Widget buildRadioButton({
      required String label,
      required int mode,
    }) {
      return Expanded(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(label),
            ),
            Radio(
              value: label,
              groupValue: currentMode,
              onChanged: (value) async {
                final pref = await SharePrefManager.prefs;

                String cmd = "";
                if (mode == 1) {
                  cmd = pref.getString(SharePrefManager.mode1) ?? "bluetooth";
                } else if (mode == 2) {
                  cmd = pref.getString(SharePrefManager.mode2) ?? "touch";
                } else if (mode == 3) {
                  cmd = pref.getString(SharePrefManager.mode3) ?? "ss";
                }

                if (value != null) {
                  context.read<BleDeviceConnectCubit>().write(cmd);
                  setState(() {
                    currentMode = value;
                  });
                }
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                "Mode điều khiển",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  final pref = await SharePrefManager.prefs;

                  final mode1 =
                      pref.getString(SharePrefManager.mode1) ?? "bluetooth";
                  final mode2 =
                      pref.getString(SharePrefManager.mode2) ?? "touch";
                  final mode3 = pref.getString(SharePrefManager.mode3) ?? "ss";

                  await showDialogChangeCmd(
                    context: context,
                    label: "Lệnh thay đổi Mode",
                    label1: "Bluetooth",
                    text1: mode1,
                    label2: "Touch",
                    text2: mode2,
                    label3: "Sensor",
                    text3: mode3,
                    onSaveText1: (value) {
                      pref.setString(SharePrefManager.mode1, value);
                    },
                    onSaveText2: (value) {
                      pref.setString(SharePrefManager.mode2, value);
                    },
                    onSaveText3: (value) {
                      pref.setString(SharePrefManager.mode3, value);
                    },
                  );
                },
                icon: Image.asset(
                  Assets.images.more.path,
                  width: 25,
                  height: 25,
                ),
              )
            ],
          ),
        ),
        Row(
          children: [
            buildRadioButton(label: controlMode[0], mode: 1),
            buildRadioButton(label: controlMode[1], mode: 2),
            buildRadioButton(label: controlMode[2], mode: 3),
          ],
        )
      ],
    );
  }

  Widget _buildControlAction() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Điều khiển Thiết bị",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          children: [
            ItemControlAction(
              module: "Đèn cầu thang",
              keyOn: SharePrefManager.led1on,
              defaultKeyOn: "led1 on",
              keyOff: SharePrefManager.led1off,
              defaultKeyOff: "led1 off",
            ),
            ItemControlAction(
              module: "Đèn tầng 2",
              keyOn: SharePrefManager.led2on,
              defaultKeyOn: "led2 on",
              keyOff: SharePrefManager.led2off,
              defaultKeyOff: "led2 off",
            ),
            ItemControlAction(
              module: "Đèn phòng khách",
              keyOn: SharePrefManager.led3on,
              defaultKeyOn: "led3 on",
              keyOff: SharePrefManager.led3off,
              defaultKeyOff: "led3 off",
            ),
            ItemControlAction(
              module: "Đèn ngoài trời",
              keyOn: SharePrefManager.led4on,
              defaultKeyOn: "led4 on",
              keyOff: SharePrefManager.led4off,
              defaultKeyOff: "led4 off",
            ),
            ItemControlAction(
              module: "Quạt phòng khách",
              keyOn: SharePrefManager.fanOn,
              defaultKeyOn: "fan on",
              keyOff: SharePrefManager.fanOff,
              defaultKeyOff: "fan off",
            ),
            ItemControlAction(
              module: "Cửa sổ",
              keyOn: SharePrefManager.wdoOn,
              defaultKeyOn: "wdo on",
              keyOff: SharePrefManager.wdoOff,
              defaultKeyOff: "wdo off",
            ),
          ],
        )
      ],
    );
  }
}
