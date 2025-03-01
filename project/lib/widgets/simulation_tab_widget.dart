import 'package:flutter/material.dart';
import 'package:leuron10_dart/model/stimulus_properties.dart';

import '../appstate.dart';

//
class SimulationTabWidget extends StatefulWidget {
  final AppState appState;

  const SimulationTabWidget({super.key, required this.appState});

  @override
  State<SimulationTabWidget> createState() => _SimulationTabWidgetState();
}

class _SimulationTabWidgetState extends State<SimulationTabWidget> {
  String? _ltpOrltd = 'LTP';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            // Two radio buttons
            Expanded(
              child: ListTile(
                title: const Text('LTP'),
                leading: Radio<String>(
                  value: 'LTP',
                  groupValue: _ltpOrltd,
                  onChanged: (value) {
                    widget.appState.stimulusProperties.lTPorlTD = value!;
                    setState(() {
                      _ltpOrltd = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('LTD'),
                leading: Radio<String>(
                  value: 'LTD',
                  groupValue: _ltpOrltd,
                  onChanged: (value) {
                    widget.appState.stimulusProperties.lTPorlTD = value!;
                    setState(() {
                      _ltpOrltd = value;
                    });
                  },
                ),
              ),
            )
          ],
        ),
        // Phaseshift
        Row(
          children: [
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
        _buildLTRegion('LTP', widget.appState.stimulusProperties.ltp, widget),
        _buildLTRegion('LTD', widget.appState.stimulusProperties.ltd, widget),
      ],
    );
  }
}

Widget _buildLTRegion(
    String title, PatternProperties properties, SimulationTabWidget widget) {
  return Padding(
    // The padding adds room for the title to move "above" container
    // edge. Without it the title is clipped.
    padding: const EdgeInsets.all(4.0),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Container(
            height: 165,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.black, width: 1.0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                  child: _buildPeriodSlider(properties, widget),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                  child: _buildIPISlider(properties, widget),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                  child: _buildBurstLengthSlider(properties, widget),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 0,
          child: Container(color: Colors.white, child: Text(title)),
        )
      ],
    ),
  );
}

Widget _buildPeriodSlider(
    PatternProperties properties, SimulationTabWidget widget) {
  return Row(
    children: [
      const Text('Period: '),
      Text(
        '(${properties.period.toString().padLeft(3, '0')})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Flexible(
        flex: 2,
        child: Slider(
          value: properties.period.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            properties.period = value.toInt();
            // Rebuild stream for selected source.
            widget.appState.update();
          },
        ),
      ),
    ],
  );
}

Widget _buildIPISlider(
    PatternProperties properties, SimulationTabWidget widget) {
  return Row(
    children: [
      const Text('IPI: '),
      Text(
        '(${properties.iPIInterval.toString().padLeft(3, '0')})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Flexible(
        flex: 2,
        child: Slider(
          value: properties.iPIInterval.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            properties.iPIInterval = value.toInt();
            // Rebuild stream for selected source.
            widget.appState.update();
          },
        ),
      ),
    ],
  );
}

Widget _buildBurstLengthSlider(
    PatternProperties properties, SimulationTabWidget widget) {
  return Row(
    children: [
      const Text('Burst Length: '),
      Text(
        '(${properties.burstLength.toString().padLeft(3, '0')})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Flexible(
        flex: 2,
        child: Slider(
          value: properties.burstLength.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            properties.burstLength = value.toInt();
            // Rebuild stream for selected source.
            widget.appState.update();
          },
        ),
      ),
    ],
  );
}
