import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../appstate.dart';
import 'checkbox_widget.dart';
import 'int_field_widget.dart';

class GlobalTabWidget extends StatefulWidget {
  final AppState appState;

  const GlobalTabWidget({super.key, required this.appState});

  @override
  State<GlobalTabWidget> createState() => _GlobalTabWidgetState();
}

class _GlobalTabWidgetState extends State<GlobalTabWidget> {
  TextEditingController queueDepthController = TextEditingController();
  TextEditingController timeScaleController = TextEditingController();
  TextEditingController rangeStartController = TextEditingController();
  TextEditingController rangeWidthController = TextEditingController();
  int rangeEnd = 0;

  @override
  Widget build(BuildContext context) {
    int queueDepth = widget.appState.properties.queueDepth;
    int rangeStart = widget.appState.properties.rangeStart;
    int rangeWidth = widget.appState.properties.rangeWidth;
    final int rangeStartHalt = queueDepth - rangeWidth;

    // The range is a fixed width.

    // The rangeStart must stop at ((queueDepth - 1) - rangeWidth).
    rangeStart = min(rangeStartHalt, rangeStart);

    // The rangeEnd can't exceed queueDepth
    rangeEnd = min(rangeStart + rangeWidth, queueDepth - 1);

    queueDepthController.text = queueDepth.toString();
    rangeStartController.text = rangeStart.toString();
    rangeWidthController.text = rangeWidth.toString();

    return Column(
      children: [
        Row(
          children: [
            IntFieldWidget(
              controller: queueDepthController,
              label: 'Queue Depth: ',
              setValue: (int value) =>
                  widget.appState.properties.queueDepth = value,
            ),
            IntFieldWidget(
              controller: timeScaleController,
              label: 'TimeScale: ',
              setValue: (int value) => () {},
            ),
          ],
        ),
        Row(
          children: [
            IntFieldWidget(
              controller: rangeStartController,
              label: 'Range Start: ',
              setValue: (int value) {
                widget.appState.properties.rangeStart = value;
              },
            ),
            IntFieldWidget(
              controller: rangeWidthController,
              label: 'Range Width: ',
              setValue: (int value) {
                widget.appState.properties.rangeWidth = value;
              },
            ),
          ],
        ),
        //
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Range slide: ',
              ),
            ),
            Text(
              '(${rangeEnd.toString().padLeft(5, '0')})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Slider(
                value: widget.appState.properties.rangeStart.toDouble(),
                min: 0,
                max: widget.appState.properties.queueDepth.toDouble(),
                divisions: 100,
                onChanged: (value) {
                  widget.appState.properties.rangeStart = value.toInt();
                  widget.appState.update();
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Synapse: ',
              ),
            ),
            Text(
              '(${widget.appState.neuronProperties.activeSynapse.toString().padLeft(3, '0')})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Slider(
                value:
                    widget.appState.neuronProperties.activeSynapse.toDouble(),
                min: 1,
                max: widget.appState.neuronProperties.synapses.toDouble(),
                divisions: 100,
                onChanged: (value) {
                  widget.appState.neuronProperties.activeSynapse =
                      value.toInt();
                  widget.appState.update();
                },
                // onChangeEnd: (value) => configWidget.config.aplay(),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Enable Noise: ',
              ),
            ),
            CheckboxWidget(
              getValue: () => widget.appState.noiseEnabled,
              setValue: (value) => widget.appState.noiseEnabled = value,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Enable Stimulus: ',
              ),
            ),
            CheckboxWidget(
              getValue: () => widget.appState.stimulusEnabled,
              setValue: (value) => widget.appState.stimulusEnabled = value,
            ),
          ],
        ),
      ],
    );
  }
}
