// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:camera/camera.dart';
import 'package:solimage/app.dart';
import './widget_test.mocks.dart';

@GenerateMocks([SolimageApp, CameraDescription])
void main() {
  var app = MockSolimageApp();
  var camera = MockCameraDescription();

  testWidgets('camera initialization test', (WidgetTester tester) async {
    when(app.initializeCamera()).thenAnswer((_) => Future.value(camera));
    await tester.pumpWidget(SolimageApp());
    expect(find.byType(CameraPreview), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}