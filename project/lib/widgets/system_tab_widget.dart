import 'package:flutter/material.dart';

import '../appstate.dart';
import 'checkbox_widget.dart';

class SystemTabWidget extends StatefulWidget {
  final AppState appState;

  const SystemTabWidget({super.key, required this.appState});

  @override
  State<SystemTabWidget> createState() => _SystemTabWidgetState();
}

class _SystemTabWidgetState extends State<SystemTabWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Toggle Surge Graph: ',
              ),
            ),
            CheckboxWidget(
                getValue: () => widget.appState.properties.graphSurge,
                setValue: (value) {
                  widget.appState.properties.graphSurge = value;
                  widget.appState.update();
                }),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Toggle PSP Graph: ',
              ),
            ),
            CheckboxWidget(
              getValue: () => widget.appState.properties.graphPsp,
              setValue: (value) {
                widget.appState.properties.graphPsp = value;
                widget.appState.update();
              },
            ),
          ],
        ),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Toggle ValueAt Graph: ',
              ),
            ),
            CheckboxWidget(
                getValue: () => widget.appState.properties.graphValueAt,
                setValue: (value) {
                  widget.appState.properties.graphValueAt = value;
                  widget.appState.update();
                }),
          ],
        ),
      ],
    );
  }
}
