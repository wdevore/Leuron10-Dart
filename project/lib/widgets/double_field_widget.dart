import 'package:flutter/material.dart';

typedef SetValueD = void Function(double);

class DoubleFieldWidget extends StatefulWidget {
  const DoubleFieldWidget(
      {super.key,
      required this.label,
      required this.setValue,
      required this.controller});

  final TextEditingController controller;
  final String label;
  final SetValueD setValue;

  @override
  State<DoubleFieldWidget> createState() => _DoubleFieldWidgetState();
}

class _DoubleFieldWidgetState extends State<DoubleFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 5, 4),
            child: Text(widget.label),
          ),
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.loose,
          child: TextField(
            controller: widget.controller,
            // inputFormatters: [FilteringIntFormatter()],
            onChanged: (value) {
              widget.setValue(double.tryParse(value) ?? 0.0);
            },
          ),
        ),
      ],
    );
  }
}
