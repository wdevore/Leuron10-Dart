import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';

import '../appstate.dart';
import '../graphs/spikes_graph_widget.dart';
import 'global_tab_widget.dart';

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
              appState.simulation.start();
              appState.simulation.run();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: const Color.fromARGB(255, 104, 58, 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Tooltip(
              message: 'Click to Begin simulation.',
              child: Text('Simulate'),
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
          weights: [0.7, 0.3], // Initial weights
          limits: [null, WeightLimit(min: 0.3, max: 0.7)], // Constraints
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
              child: PortalTarget(
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
              ),
            ),
          ],
        );
      },
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
              const Center(
                child: Text('Sim tab'),
              ),
              const Center(
                child: Text('Sys tab'),
              ),
              // SimulationPropertiesTabWidget(appState: appState),
              // SystemTabWidget(appState: appState),
            ],
          ),
        )
      ],
    ),
  );
}
