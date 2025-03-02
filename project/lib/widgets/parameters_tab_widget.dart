import 'package:flutter/material.dart';

import '../appstate.dart';
import '../model/neuron_properties.dart';
import 'double_field_widget.dart';

//
class ParametersTabWidget extends StatefulWidget {
  final AppState appState;

  const ParametersTabWidget({super.key, required this.appState});

  @override
  State<ParametersTabWidget> createState() => _ParametersTabWidgetState();
}

class _ParametersTabWidgetState extends State<ParametersTabWidget> {
  TextEditingController thresholdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double threshold = widget.appState.neuronProperties.threshold;

    thresholdController.text = threshold.toStringAsFixed(2);

    return Column(
      children: [
        DoubleFieldWidget(
          controller: thresholdController,
          label: 'Threshold: ',
          setValue: (double value) =>
              widget.appState.neuronProperties.threshold = value,
        ),
        _buildTraceRegion(
          'pre X Trace',
          widget.appState.neuronProperties.preXTraceParms,
          widget,
        ),
        _buildTraceRegion(
          'post Slow Y2 Trace',
          widget.appState.neuronProperties.postSlowY2TraceParms,
          widget,
        ),
        _buildTraceRegion(
          'post Fast Y1 Trace',
          widget.appState.neuronProperties.postFastY1TraceParms,
          widget,
        ),
      ],
    );
  }
}

Widget _buildTraceRegion(
    String title, TraceProperties properties, ParametersTabWidget widget) {
  return Padding(
    // The padding adds room for the title to move "above" container
    // edge. Without it the title is clipped.
    padding: const EdgeInsets.all(4.0),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.black, width: 1.0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: _buildASlider(properties, widget),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: _buildTaoSlider(properties, widget),
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

Widget _buildASlider(TraceProperties properties, ParametersTabWidget widget) {
  return Row(
    children: [
      const Text('A scaler: '),
      Text(
        '(${properties.a.toStringAsFixed(2).padLeft(3, '0')})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Flexible(
        flex: 2,
        child: Slider(
          value: properties.a,
          min: 0,
          max: 10.0,
          divisions: 100,
          onChanged: (value) {
            properties.a = value;
            // Rebuild stream for selected source.
            widget.appState.update();
          },
        ),
      ),
    ],
  );
}

Widget _buildTaoSlider(TraceProperties properties, ParametersTabWidget widget) {
  return Row(
    children: [
      const Text('Tao: '),
      Text(
        '(${properties.tao.toStringAsFixed(2).padLeft(3, '0')})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Flexible(
        flex: 2,
        child: Slider(
          value: properties.tao,
          min: 0.0,
          max: 100.0,
          divisions: 1000,
          onChanged: (value) {
            properties.tao = value;
            // Rebuild stream for selected source.
            widget.appState.update();
          },
        ),
      ),
    ],
  );
}
