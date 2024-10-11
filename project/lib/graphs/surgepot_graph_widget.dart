import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../appstate.dart';
import '../misc/maths.dart';
import '../model/app_properties.dart';
import '../samples/samples.dart';
import '../samples/value_sample.dart';
import 'border_clip_path.dart';

class SurgePotGraphWidget extends StatefulWidget {
  final double height;
  final Color bgColor;
  final AppState appState;
  final Samples samples;

  const SurgePotGraphWidget(
    this.appState, {
    super.key,
    required this.height,
    required this.bgColor,
    required this.samples,
  });

  @override
  State<SurgePotGraphWidget> createState() => _SurgePotGraphWidgetState();
}

class _SurgePotGraphWidgetState extends State<SurgePotGraphWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BorderClipPath(),
      child: Container(
        width: double.maxFinite,
        height: widget.height,
        color: widget.bgColor,
        child: CustomPaint(
          painter: SamplePainter(widget.samples, widget.appState),
        ),
      ),
    );
  }
}

class SamplePainter extends CustomPainter {
  late AppProperties appProperties;
  // final Environment environment;
  final AppState appState;
  final Samples samples;

  final strokeWidth = 2.0;
  final spikeRowOffset = 8;

  late Paint samplePaint;
  final Path polyLine = Path();

  SamplePainter(this.samples, this.appState) {
    appProperties = appState.properties;

    samplePaint = Paint()
      ..color = Colors.orange.shade300
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;
  }

  @override
  // Size is the physical size. <0,0> is top-left.
  // We use the Maths' functions to map data to unit-space
  // which then allows to map to graph-space.
  void paint(Canvas canvas, Size size) {
    _drawSamples(canvas, size, strokeWidth, spikeRowOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawSamples(
      Canvas canvas, Size size, double strokeWidth, int spikeRowOffset) {
    // Iterate the noise data and map samples that are within range-start
    // range-end. The data width should match width of the Input sample
    // data because the noise is "mixed in" with the input samples.

    Samples samples = appState.samples;

    // Select the queue indicated by the active synapse
    ListQueue<ValueSample> valueSamples =
        samples.surgeSamples[appState.neuronProperties.activeSynapse];
    var (rangeStart, rangeEnd) = Maths.calcRange(
      appProperties.queueDepth,
      appProperties.rangeWidth,
      appProperties.rangeStart,
    );

    polyLine.reset();

    double sample = valueSamples.elementAt(0).v;
    // Map the sample value
    // uX is the horizontal time axis
    double uX = Maths.mapSampleToUnit(
      0.0,
      rangeStart.toDouble(),
      rangeEnd.toDouble(),
    );
    double wX = Maths.mapUnitToWindow(uX, 0.0, size.width);

    double uY = Maths.mapSampleToUnit(
      sample,
      rangeStart.toDouble(),
      rangeEnd.toDouble(),
    );
    // graph space has +Y downward, but the data is oriented as +Y upward
    // so we flip in unit-space.
    uY = 1.0 - uY;
    double wY = Maths.mapUnitToWindow(uY, 0.0, size.width);

    var (lX, lY) = Maths.mapWindowToLocal(wX, wY, 0.0, 0.0);
    polyLine.moveTo(lX, lY);

    for (var t = rangeStart + 1; t < rangeEnd; t++) {
      sample = valueSamples.elementAt(t).v;

      // The sample value needs to be mapped
      double uX = Maths.mapSampleToUnit(
        t.toDouble(),
        rangeStart.toDouble(),
        rangeEnd.toDouble(),
      );
      double wX = Maths.mapUnitToWindow(uX, 0.0, size.width);

      double uY = Maths.mapSampleToUnit(
        sample,
        samples.synapseSurgeMin,
        samples.synapseSurgeMax,
      );

      // graph space has +Y downward, but the data is oriented as +Y upward
      // so we flip in unit-space.
      uY = 1.0 - uY;
      double wY = Maths.mapUnitToWindow(uY, 0.0, size.width);

      (lX, lY) = Maths.mapWindowToLocal(wX, wY, 0.0, 0.0);
      polyLine.lineTo(lX, lY);
    }

    // Now plot line.
    canvas.drawPath(polyLine, samplePaint);
  }
}
