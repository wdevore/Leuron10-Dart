import 'package:flutter/material.dart';

import '../appstate.dart';

//
class SimulationTabWidget extends StatefulWidget {
  final AppState appState;

  const SimulationTabWidget({super.key, required this.appState});

  @override
  State<SimulationTabWidget> createState() => _SimulationTabWidgetState();
}

class _SimulationTabWidgetState extends State<SimulationTabWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Slider to control phase shift of 2 stimulus
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Phaseshift: ',
              ),
            ),
            Text(
              '(${widget.appState.properties.phaseShift.toString()})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Slider(
                value: widget.appState.properties.phaseShift.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  widget.appState.properties.phaseShift = value.toInt();
                  // Rebuild stream for selected source.
                  widget.appState
                      .changePhase(widget.appState.properties.phaseShift);
                  widget.appState.update();
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 5, 4),
              child: Text(
                'Frequency: ',
              ),
            ),
            Text(
              '(${widget.appState.properties.freqStimulus.toString()})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Slider(
                value: widget.appState.properties.freqStimulus.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  widget.appState.properties.freqStimulus = value.toInt();
                  // Rebuild stream for selected source.
                  widget.appState
                      .changeFrequency(widget.appState.properties.freqStimulus);
                  widget.appState.update();
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
