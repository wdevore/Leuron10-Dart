import 'package:flutter/material.dart';

import '../appstate.dart';
import 'checkbox_widget.dart';

class GraphsTabWidget extends StatefulWidget {
  final AppState appState;

  const GraphsTabWidget({super.key, required this.appState});

  @override
  State<GraphsTabWidget> createState() => _GraphsTabWidgetState();
}

class _GraphsTabWidgetState extends State<GraphsTabWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            CheckboxWidget(
                getValue: () => widget.appState.properties.graphSurge,
                setValue: (value) {
                  widget.appState.properties.graphSurge = value;
                  widget.appState.update();
                }),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Surge Graph ',
              ),
            ),
          ],
        ),
        Row(
          children: [
            CheckboxWidget(
              getValue: () => widget.appState.properties.graphPsp,
              setValue: (value) {
                widget.appState.properties.graphPsp = value;
                widget.appState.update();
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'PSP Graph ',
              ),
            ),
          ],
        ),
        Row(
          children: [
            CheckboxWidget(
                getValue: () => widget.appState.properties.graphPreTrace,
                setValue: (value) {
                  widget.appState.properties.graphPreTrace = value;
                  widget.appState.update();
                }),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'preTrace Graph ',
              ),
            ),
          ],
        ),
        Row(
          children: [
            CheckboxWidget(
                getValue: () => widget.appState.properties.graphValueAt,
                setValue: (value) {
                  widget.appState.properties.graphValueAt = value;
                  widget.appState.update();
                }),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'ValueAt Graph ',
              ),
            ),
          ],
        ),
        Row(
          children: [
            CheckboxWidget(
                getValue: () => widget.appState.properties.graphPostY2Trace,
                setValue: (value) {
                  widget.appState.properties.graphPostY2Trace = value;
                  widget.appState.update();
                }),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'PostY2Trace Graph ',
              ),
            ),
          ],
        ),
        Row(
          children: [
            CheckboxWidget(
                getValue: () => widget.appState.properties.graphweights,
                setValue: (value) {
                  widget.appState.properties.graphweights = value;
                  widget.appState.update();
                }),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Weight Graph ',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
