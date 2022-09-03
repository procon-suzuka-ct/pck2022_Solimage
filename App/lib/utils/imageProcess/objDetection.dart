import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'coordinates.dart';

class ObjectDetection {
  static final ObjectDetection _singleton = ObjectDetection._internal();
  static ObjectDetection get instance => _singleton;
  ObjectDetection._internal();

  final ObjectDetector objectDetector = GoogleMlKit.vision.objectDetector(
      options: ObjectDetectorOptions(
          mode: DetectionMode.single,
          classifyObjects: false,
          multipleObjects: true));

  Future<Coordinates> detect(CameraImage image) {
    final WriteBuffer allBytesBuffer = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytesBuffer.putUint8List(plane.bytes);
    }
    final Uint8List allBytes = allBytesBuffer.done().buffer.asUint8List();

    final InputImage inputImage = InputImage.fromBytes(
        bytes: allBytes,
        inputImageData: InputImageData(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            imageRotation: InputImageRotation.rotation90deg,
            inputImageFormat:
                InputImageFormatValue.fromRawValue(image.format.raw) ??
                    InputImageFormat.nv21,
            planeData: image.planes.map((Plane plane) {
              return InputImagePlaneMetadata(
                bytesPerRow: plane.bytesPerRow,
                height: plane.height,
                width: plane.width,
              );
            }).toList()));

    return objectDetector.processImage(inputImage).then((value) {
      final List<List<double>> coordinates = [];
      for (final obj in value) {
        coordinates.add([
          obj.boundingBox.left,
          obj.boundingBox.top,
          obj.boundingBox.right,
          obj.boundingBox.bottom
        ]);
      }
      return Coordinates(
          objNum: coordinates.length, objCoordinates: coordinates);
    });
  }
}
