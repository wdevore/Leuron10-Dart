import 'package:flutter/material.dart';

typedef SetCheckValue = void Function(bool);
typedef GetCheckValue = bool Function();

class CheckboxWidget extends StatefulWidget {
  final SetCheckValue setValue;
  final GetCheckValue getValue;

  const CheckboxWidget(
      {super.key, required this.setValue, required this.getValue});

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.getValue(),
      onChanged: (bool? value) {
        setState(() {
          widget.setValue(value!);
        });
      },
    );
  }
}
