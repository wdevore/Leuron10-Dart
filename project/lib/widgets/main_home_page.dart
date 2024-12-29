import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';

import '../appstate.dart';
import '../graphs/psp_graph_widget.dart';
import '../graphs/samples_graph_widget.dart';
import '../graphs/spikes_graph_widget.dart';
import '../graphs/surgepot_graph_widget.dart';
import '../graphs/value_at_graph_widget.dart';
import '../samples/sample_list.dart';
import '../samples/samples_data.dart';
import 'global_tab_widget.dart';
import 'simulation_tab_widget.dart';
import 'system_tab_widget.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key, required this.title});

  final String title;

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Consumer<AppState>(
          builder: (context, value, child) {
            return Text(
                'Time: ${appState.simulation.simTime.toStringAsFixed(2)}');
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Create Start simulation
              if (appState.simulation.isRunning) {
                appState.simulation.stop();
              } else {
                appState.simulation.start();
                appState.simulation.run();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: const Color.fromARGB(255, 104, 58, 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Tooltip(
              message: 'Click to Toggle simulation.',
              child: Consumer<AppState>(
                builder: (BuildContext context, AppState value, Widget? child) {
                  return Text(
                      appState.simulation.isRunning ? 'Pause' : 'Simulate');
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Reset simulation
              appState.simulation.reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: const Color.fromARGB(255, 104, 58, 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Tooltip(
              message: 'Click to Reset simulation.',
              child: Text('Reset'),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Stop simulation
              appState.simulation.stop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: const Color.fromARGB(255, 104, 58, 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Tooltip(
              message: 'Click to Stop simulation.',
              child: Text('Stop'),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
        activeIndicator: const SplitIndicator(
          viewMode: SplitViewMode.Horizontal,
          isActive: true,
          color: Colors.lime,
        ),
        controller: SplitViewController(
          weights: [0.65, 0.35], // Initial weights
          limits: [null, WeightLimit(min: 0.35, max: 0.65)], // Constraints
        ),
        children: [
          _buildGraphView(appState),
          _buildTabBar(),
        ],
      ),
    );
  }
}

Widget _buildGraphView(AppState appState) {
  return SingleChildScrollView(
    child: Consumer<AppState>(
      builder: (BuildContext context, AppState appState, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Portal(
              child: _buildSpikesGraph(appState),
            ),
            Portal(
              child: _buildWeightsGraph(appState),
            ),
            Portal(
              child: _buildPreTraceGraph(appState),
            ),
            Portal(
              child: _buildPostY2TraceGraph(appState),
            ),
            // Portal(
            //   child: _buildValueAtGraph(appState),
            // ),
            // Portal(
            //   child: _buildSurgeGraph(appState),
            // ),
            // Portal(
            //   child: _buildPspGraph(appState),
            // ),
          ],
        );
      },
    ),
  );
}

Widget _buildSpikesGraph(AppState appState) {
  return PortalTarget(
    anchor: const Aligned(
      follower: Alignment.topLeft,
      target: Alignment.topLeft,
      offset: Offset(5, 5),
    ),
    visible: true,
    portalFollower: const Text(
      'Spikes',
      style: TextStyle(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: SpikesGraphWidget(
        appState,
        samples: appState.samples,
        height: 180.0,
        bgColor: Colors.black87,
      ),
    ),
  );
}

Widget _buildPreTraceGraph(AppState appState) {
  if (!appState.properties.graphPreTrace) return Container();
  SampleList list =
      appState.samples.samplesData.lists[SamplesIndex.preTrace.index];

  return PortalTarget(
    anchor: const Aligned(
      follower: Alignment.topLeft,
      target: Alignment.topLeft,
      offset: Offset(5, 5),
    ),
    visible: true,
    portalFollower: Text(
      'PreTrace (${list.minV.toStringAsFixed(2)}, ${list.maxV.toStringAsFixed(2)})',
      style: const TextStyle(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: SamplesGraphWidget(
        appState,
        samples: appState.samples,
        height: 180.0,
        bgColor: Colors.black87,
        index: SamplesIndex.preTrace,
      ),
    ),
  );
}

Widget _buildPostY2TraceGraph(AppState appState) {
  if (!appState.properties.graphPostY2Trace) return Container();
  SampleList list =
      appState.samples.samplesData.lists[SamplesIndex.postY2Trace.index];

  return PortalTarget(
    anchor: const Aligned(
      follower: Alignment.topLeft,
      target: Alignment.topLeft,
      offset: Offset(5, 5),
    ),
    visible: true,
    portalFollower: Text(
      'PostY2Trace (${list.minV.toStringAsFixed(2)}, ${list.maxV.toStringAsFixed(2)})',
      style: const TextStyle(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: SamplesGraphWidget(
        appState,
        samples: appState.samples,
        height: 180.0,
        bgColor: Colors.black87,
        index: SamplesIndex.postY2Trace,
      ),
    ),
  );
}

Widget _buildWeightsGraph(AppState appState) {
  if (!appState.properties.graphweights) return Container();
  SampleList list =
      appState.samples.samplesData.lists[SamplesIndex.weights.index];

  return PortalTarget(
    anchor: const Aligned(
      follower: Alignment.topLeft,
      target: Alignment.topLeft,
      offset: Offset(5, 5),
    ),
    visible: true,
    portalFollower: Text(
      'Weight (${list.minV.toStringAsFixed(2)}, ${list.maxV.toStringAsFixed(2)})',
      style: const TextStyle(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: SamplesGraphWidget(
        appState,
        samples: appState.samples,
        height: 180.0,
        bgColor: Colors.black87,
        index: SamplesIndex.weights,
      ),
    ),
  );
}

Widget _buildSurgeGraph(AppState appState) {
  if (!appState.properties.graphSurge) return Container();

  return PortalTarget(
    anchor: const Aligned(
      follower: Alignment.topLeft,
      target: Alignment.topLeft,
      offset: Offset(5, 5),
    ),
    visible: true,
    portalFollower: const Text(
      'Surge',
      style: TextStyle(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: SurgePotGraphWidget(
        appState,
        samples: appState.samples,
        height: 180.0,
        bgColor: Colors.black87,
      ),
    ),
  );
}

Widget _buildPspGraph(AppState appState) {
  if (!appState.properties.graphPsp) return Container();

  return PortalTarget(
    anchor: const Aligned(
      follower: Alignment.topLeft,
      target: Alignment.topLeft,
      offset: Offset(5, 5),
    ),
    visible: true,
    portalFollower: const Text(
      'Psp',
      style: TextStyle(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: PspGraphWidget(
        appState,
        samples: appState.samples,
        height: 180.0,
        bgColor: Colors.black87,
      ),
    ),
  );
}

Widget _buildValueAtGraph(AppState appState) {
  if (!appState.properties.graphValueAt) return Container();

  return PortalTarget(
    anchor: const Aligned(
      follower: Alignment.topLeft,
      target: Alignment.topLeft,
      offset: Offset(5, 5),
    ),
    visible: true,
    portalFollower: Text(
      'ValueAt (${appState.samples.samplesData.valueAt.minV.toStringAsFixed(2)}, ${appState.samples.samplesData.valueAt.maxV.toStringAsFixed(2)})',
      style: const TextStyle(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ValueAtGraphWidget(
        appState,
        samples: appState.samples,
        height: 180.0,
        bgColor: Colors.black87,
      ),
    ),
  );
}

Widget _buildTabBar() {
  return DefaultTabController(
    length: 3,
    child: Column(
      children: [
        const SizedBox(
          height: 50,
          child: TabBar(
            tabs: [
              Text(
                'Global',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Simulation',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'System',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              Consumer<AppState>(
                builder:
                    (BuildContext context, AppState appState, Widget? child) {
                  return GlobalTabWidget(appState: appState);
                },
              ),
              Consumer<AppState>(
                builder:
                    (BuildContext context, AppState appState, Widget? child) {
                  return SimulationTabWidget(appState: appState);
                },
              ),
              Consumer<AppState>(
                builder:
                    (BuildContext context, AppState appState, Widget? child) {
                  return SystemTabWidget(appState: appState);
                },
              ),
              // SimulationPropertiesTabWidget(appState: appState),
            ],
          ),
        )
      ],
    ),
  );
}
