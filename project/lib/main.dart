import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appstate.dart';
import 'widgets/main_home_page.dart';

void main() {
  AppState appState = AppState.create()
    ..configure(
      'lib/model/app_properties.json',
      'lib/model/neuron_properties.json',
      'synapse_preset_1.json',
    );

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leuron10',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainHomePage(title: 'Leuron10'),
    );
  }
}
