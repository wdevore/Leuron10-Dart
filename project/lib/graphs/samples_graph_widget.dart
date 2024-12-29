import 'dart:collection';

import 'package:flutter/material.dart';

import '../appstate.dart';
import '../misc/maths.dart';
import '../model/app_properties.dart';
import '../samples/sample_list.dart';
import '../samples/samples.dart';
import '../samples/samples_data.dart';
import '../samples/value_sample.dart';
import 'border_clip_path.dart';

class SamplesGraphWidget extends StatefulWidget {
  final double height;
  final Color bgColor;
  final AppState appState;
  final Samples samples;
  final SamplesIndex index;

  const SamplesGraphWidget(
    this.appState, {
    super.key,
    required this.height,
    required this.bgColor,
    required this.samples,
    required this.index,
  });

  @override
  State<SamplesGraphWidget> createState() => _SamplesGraphWidgetState();
}

class _SamplesGraphWidgetState extends State<SamplesGraphWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BorderClipPath(),
      child: Container(
        width: double.maxFinite,
        height: widget.height,
        color: widget.bgColor,
        child: CustomPaint(
          painter: SamplePainter(widget.samples, widget.appState, widget.index),
        ),
      ),
    );
  }
}

class SamplePainter extends CustomPainter {
  late AppProperties appProperties;
  final AppState appState;
  final Samples samples;
  final SamplesIndex index;

  final strokeWidth = 1.0;

  late Paint samplePaint;
  final Path polyLine = Path();

  SamplePainter(this.samples, this.appState, this.index) {
    appProperties = appState.properties;

    samplePaint = Paint()
      ..color = Colors.orange.shade300
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
  }

  @override
  // Size is the physical size. <0,0> is top-left.
  // We use the Maths' functions to map data to unit-space
  // which then allows us to map to graph-space.
  void paint(Canvas canvas, Size size) {
    _drawSamples(canvas, size, strokeWidth, index);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawSamples(
      Canvas canvas, Size size, double strokeWidth, SamplesIndex samplesIndex) {
    // Select the queue indicated by the active synapse
    SamplesData data = samples.samplesData;
    SampleList dataL = data.lists[samplesIndex.index];

    ListQueue<ValueSample> valueSamples =
        dataL.samples[appState.neuronProperties.activeSynapse];

    var (rangeStart, rangeEnd) = Maths.calcRange(
      appProperties.queueDepth,
      appProperties.rangeWidth,
      appProperties.rangeStart,
    );

    polyLine.reset();

    // Map the sample value
    var (lX, lY) =
        mapPoint(rangeStart, size, valueSamples, dataL, rangeStart, rangeEnd);
    polyLine.moveTo(lX, lY);

    for (var i = rangeStart + 1; i < rangeEnd; i++) {
      (lX, lY) = mapPoint(i, size, valueSamples, dataL, rangeStart, rangeEnd);
      polyLine.lineTo(lX, lY);
    }

    // Now plot line.
    canvas.drawPath(polyLine, samplePaint);
  }

  (double, double) mapPoint(
    int index,
    Size size,
    ListQueue<ValueSample> valueSamples,
    SampleList dataL,
    int rangeStart,
    int rangeEnd,
  ) {
    double sample = valueSamples.elementAt(index).v;
    // The sample value needs to be mapped
    double uX = Maths.mapSampleToUnit(
      index.toDouble(),
      rangeStart.toDouble(),
      rangeEnd.toDouble(),
    );
    double wX = Maths.mapUnitToWindow(uX, 0.0, size.width);

    double uY = Maths.mapSampleToUnit(sample, dataL.minV, dataL.maxV);

    // graph space has +Y downward, but the data is oriented as +Y upward
    // so we flip in unit-space.
    uY = 1.0 - uY;

    double wY = Maths.mapUnitToWindow(uY, 0.0, size.height);

    return Maths.mapWindowToLocal(wX, wY, 0.0, 0.0);
  }
}
