import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../appstate.dart';
import '../misc/maths.dart';
import '../model/app_properties.dart';
import '../samples/input_sample.dart';
import '../samples/samples.dart';
import '../samples/soma_sample.dart';
import 'border_clip_path.dart';

// This graph renders chains of Spikes: Noise, Stimulus and
// Soma spikes.
// Each spike is a either a dot or vertical lines about N pixels in height
// Each row is seperated by ~2px.
// Poisson spikes are orange, AP spikes are green.
// Poisson is drawn first then AP.
//
// Graph is shaped like this:
//      .----------------> +X
//  1   :  |   ||     |   | |       ||     |
//  2   :    |   |   ||     ||     |    |        <-- a row ~2px height
//  3   :   |    |    |         | |   |     |
//      v
//      +Y
//
// Only the X-axis is mapped Y is simply a height in graph-space.
//
// This graph also shows the Neuron's Post spike (i.e. the output of the neuron)

class SpikesGraphWidget extends StatefulWidget {
  final double height;
  final Color bgColor;
  final AppState appState;
  final Samples samples;

  const SpikesGraphWidget(
    this.appState, {
    super.key,
    required this.height,
    required this.bgColor,
    required this.samples,
  });

  @override
  State<SpikesGraphWidget> createState() => _SpikesGraphWidgetState();
}

class _SpikesGraphWidgetState extends State<SpikesGraphWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BorderClipPath(),
      child: Container(
        width: double.maxFinite,
        height: widget.height,
        color: widget.bgColor,
        child: CustomPaint(
          painter: SpikePainter(widget.samples, widget.appState),
        ),
      ),
    );
  }
}

class SpikePainter extends CustomPainter {
  late AppProperties appProperties;
  // final Environment environment;
  final AppState appState;
  final Samples samples;
  // Mapped points
  List<Offset> points = [];

  final strokeWidth = 4.0;
  final spikeRowOffset = 8;

  late Paint someSpikePaint;
  late Paint noisePaint;
  late Paint stimulusPaint;

  SpikePainter(this.samples, this.appState) {
    appProperties = appState.properties;

    noisePaint = Paint()
      ..color = Colors.yellow.shade600
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    stimulusPaint = Paint()
      ..color = Colors.green.shade600
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;
  }

  @override
  // Size is the physical size. <0,0> is top-left.
  // We use the Maths' functions to map data to unit-space
  // which then allows to map to graph-space.
  void paint(Canvas canvas, Size size) {
    if (appState.noiseEnabled) {
      _drawNoise(canvas, size, strokeWidth, spikeRowOffset);
    }
    if (appState.stimulusEnabled) {
      _drawStimulus(canvas, size, strokeWidth, spikeRowOffset);
    }
    // _drawSomaSpikes(canvas, size, strokeWidth, appState);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawNoise(
      Canvas canvas, Size size, double strokeWidth, int spikeRowOffset) {
    points.clear();

    double wY = 5.0;

    // Iterate the noise data and map samples that are within range-start
    // range-end. The data width should match width of the Input sample
    // data because the noise is "mixed in" with the input samples.

    List<ListQueue<InputSample>> noiseSamples = appState.samples.noiseSamples;
    var (rangeStart, rangeEnd) = Maths.calcRange(
      appProperties.queueDepth,
      appProperties.rangeWidth,
      appProperties.rangeStart,
    );

    for (ListQueue<InputSample> queue in noiseSamples) {
      for (var t = rangeStart; t < rangeEnd; t++) {
        // Spiked?
        if (queue.elementAt(t).input == 1) {
          // The sample value needs to be mapped
          final double uX = Maths.mapSampleToUnit(
              t.toDouble(), rangeStart.toDouble(), rangeEnd.toDouble());
          final double wX = Maths.mapUnitToWindow(uX, 0.0, size.width);
          var (lX, lY) = Maths.mapWindowToLocal(wX, wY, 0.0, 0.0);
          points.add(Offset(lX, lY));
        }
      }
      // Update row/y value and offset by a few pixels
      wY += spikeRowOffset;
    }

    // Now plot all mapped points.
    canvas.drawPoints(PointMode.points, points, noisePaint);
  }

  void _drawStimulus(
      Canvas canvas, Size size, double strokeWidth, int spikeRowOffset) {
    points.clear();

    double wY = 85.0;

    // Iterate the noise data and map samples that are within range-start
    // range-end. The data width should match width of the Input sample
    // data because the noise is "mixed in" with the input samples.

    List<ListQueue<InputSample>> stimulusSamples =
        appState.samples.stimulusSamples;
    var (rangeStart, rangeEnd) = Maths.calcRange(
      appProperties.queueDepth,
      appProperties.rangeWidth,
      appProperties.rangeStart,
    );

    for (ListQueue<InputSample> queue in stimulusSamples) {
      for (var t = rangeStart; t < rangeEnd; t++) {
        // Spiked?
        if (queue.elementAt(t).input == 1) {
          // The sample value needs to be mapped
          final double uX = Maths.mapSampleToUnit(
              t.toDouble(), rangeStart.toDouble(), rangeEnd.toDouble());
          final double wX = Maths.mapUnitToWindow(uX, 0.0, size.width);
          var (lX, lY) = Maths.mapWindowToLocal(wX, wY, 0.0, 0.0);
          points.add(Offset(lX, lY));
        }
      }
      // Update row/y value and offset by a few pixels
      wY += spikeRowOffset;
    }

    // Now plot all mapped points.
    canvas.drawPoints(PointMode.points, points, stimulusPaint);
  }

  void _drawSomaSpikes(
      Canvas canvas, Size size, double strokeWidth, AppState appState) {
    double bottom = size.height;

    List<SomaSample> somaSamples = appState.samples.somaSamples;
    int rangeEnd = appProperties.rangeStart + appProperties.rangeWidth;
    if (somaSamples.isEmpty) return;

    for (var t = appProperties.rangeStart; t < rangeEnd; t++) {
      // A spike = 1
      if (somaSamples[t].output == 1) {
        // The sample value needs to be mapped
        double uX = Maths.mapSampleToUnit(
          t.toDouble(),
          appProperties.rangeStart.toDouble(),
          rangeEnd.toDouble(),
        );
        double wX = Maths.mapUnitToWindow(uX, 0.0, size.width);

        var (lX, lY) = Maths.mapWindowToLocal(wX, bottom, 0.0, 0.0);

        // graph space has +Y downward, but the data is oriented as +Y upward
        // so we flip in unit-space.
        // uY = 1.0 - uY;
        // double wY = Maths.mapUnitToWindow(uY, 0.0, bottom);

        canvas.drawLine(Offset(lX, lY), Offset(lX, lY - 10), someSpikePaint);
      }
    }
  }
}
