import 'package:flutter/material.dart';
import 'package:leuron10_dart/model/stimulus_properties.dart';

import '../appstate.dart';
import '../model/app_properties.dart';

//
class StimulationTabWidget extends StatefulWidget {
  final AppState appState;

  const StimulationTabWidget({super.key, required this.appState});

  @override
  State<StimulationTabWidget> createState() => _StimulationTabWidgetState();
}

class _StimulationTabWidgetState extends State<StimulationTabWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioLTPLTD(appState: widget.appState),
        // Phaseshift
        _buildPhaseshiftSlider(widget.appState.properties, widget),
        _buildLTRegion('LTP', widget.appState.stimulusProperties.ltp, widget),
        _buildLTRegion('LTD', widget.appState.stimulusProperties.ltd, widget),
      ],
    );
  }
}

class RadioLTPLTD extends StatefulWidget {
  final AppState appState;

  const RadioLTPLTD({super.key, required this.appState});

  @override
  State<RadioLTPLTD> createState() => _RadioLTPLTDState();
}

class _RadioLTPLTDState extends State<RadioLTPLTD> {
  String? _ltpOrltd;

  @override
  Widget build(BuildContext context) {
    _ltpOrltd = widget.appState.stimulusProperties.lTPorlTD;

    return Row(
      children: <Widget>[
        // A Flex container to force radios to bunch together in the middle.
        // As long as the radios have a larger flex value >1.
        Flexible(child: Container()),
        Flexible(
          flex: 2,
          child: RadioListTile(
            title: const Text('LTP'),
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
        Flexible(
          flex: 2,
          child: RadioListTile(
            title: const Text('LTD'),
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
        Flexible(child: Container()),
      ],
    );
  }
}

Widget _buildLTRegion(
    String title, PatternProperties properties, StimulationTabWidget widget) {
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
    PatternProperties properties, StimulationTabWidget widget) {
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
    PatternProperties properties, StimulationTabWidget widget) {
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
    PatternProperties properties, StimulationTabWidget widget) {
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

Widget _buildPhaseshiftSlider(
    AppProperties properties, StimulationTabWidget widget) {
  return Row(
    children: [
      Flexible(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
          child: Row(
            children: [
              const Text('Phase shift: '),
              Text(
                '(${properties.phaseShift.toString().padLeft(3, '0')})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Slider(
                  value: properties.phaseShift.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    properties.phaseShift = value.toInt();
                    // Rebuild stream for selected source.
                    widget.appState
                        .changePhase(widget.appState.properties.phaseShift);
                    widget.appState.update();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
