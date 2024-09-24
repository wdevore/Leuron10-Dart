import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SetValueI = void Function(int);

class IntFieldWidget extends StatefulWidget {
  const IntFieldWidget(
      {super.key,
      required this.label,
      required this.setValue,
      required this.controller});

  final TextEditingController controller;
  final String label;
  final SetValueI setValue;

  @override
  State<IntFieldWidget> createState() => _IntFieldWidgetState();
}

class _IntFieldWidgetState extends State<IntFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 5, 4),
            child: Text(widget.label),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              // inputFormatters: [FilteringIntFormatter()],
              onChanged: (value) {
                widget.setValue(int.tryParse(value) ?? 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilteringIntFormatter extends TextInputFormatter {
  final _intFormatter = FilteringTextInputFormatter.allow(RegExp(r'\d+'));
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    var decs = newValue.text.replaceAll(RegExp(r'[a-zA-Z.]'), '');
    var value =
        _intFormatter.formatEditUpdate(oldValue, TextEditingValue(text: decs));
    var flt = value.text;
    return TextEditingValue(
        text: flt, selection: TextSelection.collapsed(offset: flt.length));
  }
}
