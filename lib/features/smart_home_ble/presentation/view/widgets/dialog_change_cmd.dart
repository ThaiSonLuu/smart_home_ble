import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<BluetoothDevice?> showDialogChangeCmd({
  required BuildContext context,
  required String label,
  String? label1,
  String? text1,
  String? label2,
  String? text2,
  String? label3,
  String? text3,
  Function(String)? onSaveText1,
  Function(String)? onSaveText2,
  Function(String)? onSaveText3,
}) async {
  return await showDialog<BluetoothDevice?>(
    context: context,
    builder: (context) {
      return Dialog(
        child: ChangeCmdDialog(
          label: label,
          label1: label1,
          text1: text1,
          label2: label2,
          text2: text2,
          label3: label3,
          text3: text3,
          onSaveText1: onSaveText1,
          onSaveText2: onSaveText2,
          onSaveText3: onSaveText3,
        ),
      );
    },
  );
}

class ChangeCmdDialog extends StatefulWidget {
  const ChangeCmdDialog({
    super.key,
    required this.label,
    this.label1,
    this.text1,
    this.label2,
    this.text2,
    this.label3,
    this.text3,
    this.onSaveText1,
    this.onSaveText2,
    this.onSaveText3,
  });

  final String label;

  final String? label1;
  final String? text1;

  final String? label2;
  final String? text2;

  final String? label3;
  final String? text3;

  final Function(String)? onSaveText1;
  final Function(String)? onSaveText2;
  final Function(String)? onSaveText3;

  @override
  State<ChangeCmdDialog> createState() => _ChangeCmdDialogState();
}

class _ChangeCmdDialogState extends State<ChangeCmdDialog> {
  late final TextEditingController controller1;
  late final TextEditingController controller2;
  late final TextEditingController controller3;

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController(text: widget.text1 ?? "");
    controller2 = TextEditingController(text: widget.text2 ?? "");
    controller3 = TextEditingController(text: widget.text3 ?? "");
  }

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (widget.label1 != null && widget.onSaveText1 != null) ...[
              const SizedBox(height: 10),
              Text(
                "${widget.label1!}:",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                controller: controller1,
              )
            ],
            if (widget.label2 != null && widget.onSaveText2 != null) ...[
              const SizedBox(height: 10),
              Text(
                "${widget.label2!}:",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                controller: controller2,
              )
            ],
            if (widget.label3 != null && widget.onSaveText3 != null) ...[
              const SizedBox(height: 10),
              Text(
                "${widget.label3!}:",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                controller: controller3,
              )
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSaveText1?.call(controller1.text);
                    widget.onSaveText2?.call(controller2.text);
                    widget.onSaveText3?.call(controller3.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Lưu"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
