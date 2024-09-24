// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Decay function', () {
    double psp = 0.0;
    double m = 0.05; // decay rate
    double ts = 0.0;
    double surge = 4.0;
    double dt = 0.0;
    double epsilon = 0.000001;

    for (double t = 0; t < 15; t += 0.1) {
      if (t >= (5.0 - epsilon) && t <= (5.0 + epsilon)) {
        // spike
        print('spike: $t');
        psp += surge;
        ts = t;
      }

      if (t >= (7.5 - epsilon) && t <= (7.5 + epsilon)) {
        print('spike: $t');
        psp += surge;
        ts = t;
      }
      print('t: $t, psp: $psp');
      psp -= m;
      psp = max(0.0, psp);
    }
  });
  // testWidgets('Decay function', (WidgetTester tester) async {
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
}
