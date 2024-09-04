import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_ble/features/smart_home_ble/data/local/share_pref_manager.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/logic/device_connect/ble_device_connect_cubit.dart';
import 'package:smart_home_ble/features/smart_home_ble/presentation/view/widgets/dialog_change_cmd.dart';
import 'package:smart_home_ble/gen/assets.gen.dart';

class ItemControlAction extends StatefulWidget {
  const ItemControlAction({
    super.key,
    required this.module,
    required this.keyOn,
    required this.defaultKeyOn,
    required this.keyOff,
    required this.defaultKeyOff,
  });

  final String module;
  final String keyOn;
  final String defaultKeyOn;
  final String keyOff;
  final String defaultKeyOff;

  @override
  State<ItemControlAction> createState() => _ItemControlActionState();
}

class _ItemControlActionState extends State<ItemControlAction> {
  bool currentValue = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(widget.module)),
          Switch(
            value: currentValue,
            onChanged: (value) async {
              final pref = await SharePrefManager.prefs;

              String cmd = "";
              if (value) {
                cmd = pref.getString(widget.keyOn) ?? widget.defaultKeyOn;
              } else{
                cmd = pref.getString(widget.keyOff) ?? widget.defaultKeyOff;
              }

              context.read<BleDeviceConnectCubit>().write(cmd);

              setState(
                () {
                  currentValue = value;
                },
              );
            },
          ),
          IconButton(
            onPressed: () async {
              final pref = await SharePrefManager.prefs;

              final onCmd = pref.getString(widget.keyOn) ?? widget.defaultKeyOn;
              final offCmd = pref.getString(widget.keyOff) ?? widget.defaultKeyOff;

              await showDialogChangeCmd(
              context: context,
              label: "Lệnh điều khiển",
              label1: "On",
              text1: onCmd,
              label2: "Off",
              text2: offCmd,
              onSaveText1: (value) {
                pref.setString(widget.keyOn, value);
              },
              onSaveText2: (value) {
                pref.setString(widget.keyOff, value);
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
    );
  }
}
