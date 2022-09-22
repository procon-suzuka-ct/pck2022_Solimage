import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:solimage/utils/imageProcess/imageUtil.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  //singleton
  static final Classifier _singleton = Classifier._internal();
  static Classifier get instance => _singleton;
  // 変更済み（ここから）
  Classifier._internal() {
    _interpreterOptions.threads = 1;
    _interpreterOptions.useNnApiForAndroid = true;
  }

  Classifier() {
    _interpreterOptions.threads = 1;
  }
  // 変更済み（ここまで）

  late Interpreter _interpreter;
  final _interpreterOptions = InterpreterOptions();

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorBuffer _outputBuffer;
  late TfLiteType _inputType;
  late TfLiteType _outputType;

  final NormalizeOp _preProcessNormalizeOp = NormalizeOp(0, 1);

  TensorImage preProcess(TensorImage inputImage) {
    int cropSize = min(inputImage.height, inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
            _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .add(_preProcessNormalizeOp)
        .build()
        .process(inputImage);
  }

  Future<void> loadModel() async {
    try {
      // 量子化したモデルは動かすとクラッシュするのでfirebaseは使わない
      //_modelFile = await FirebaseModelDownloader.instance
      //    .getModel(
      //        "solimage-special",
      //        FirebaseModelDownloadType.localModel,
      //        FirebaseModelDownloadConditions(
      //          iosAllowsCellularAccess: true,
      //          iosAllowsBackgroundDownloading: false,
      //          androidChargingRequired: false,
      //          androidWifiRequired: false,
      //          androidDeviceIdleRequired: false,
      //        ))
      //    .then((value) => value.file);
      _interpreter = await Interpreter.fromAsset("model.tflite",
          options: _interpreterOptions);
      _inputShape = _interpreter.getInputTensor(0).shape;
      _inputType = _interpreter.getInputTensor(0).type;
      _outputShape = _interpreter.getOutputTensor(0).shape;
      _outputType = _interpreter.getOutputTensor(0).type;
      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      return;
    } catch (e) {
      throw Exception("Failed to load model");
    }
  }

  /// Only [Image] or [CameraImage] arguments are allowed.
  ///
  /// If other types are passed, an exception will be thrown.
  ///
  /// usage:
  /// ```dart
  /// final result = await Classifier.instance.predict(image);
  /// final labels = Classifier.getLabelIndexes(result);
  /// for (var label in labels.keys) {
  ///   final labelName = await Classifier.getLabel(label);
  ///   print("$labelName: ${labels[label]}%");
  /// }
  /// ```
  Future<List<double>> predict(Object image) async {
    if (image is CameraImage) {
      image = ImageUtils.convertYUV420ToImage(image);
    }
    if (image is! Image) {
      throw Exception("Invalid image type");
    }
    await loadModel();
    TensorImage inputImage = TensorImage(_inputType);
    inputImage.loadImage(image);
    inputImage = preProcess(inputImage);

    _interpreter.run(inputImage.buffer, _outputBuffer.getBuffer());
    return _outputBuffer.getDoubleList();
  }

  static Map<int, double> getLabelIndexes(List<double> predictResults) {
    var values = predictResults;
    values.sort();
    values = values.reversed.toList();
    values = values.sublist(0, 4);
    Map<int, double> labels = {};
    for (var value in values) {
      labels[predictResults.indexOf(value)] = value;
    }
    return labels;
  }

  static Future<String> getLabel(int index) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('ml/labels_reverse.json');
    final url = await ref.getDownloadURL();
    final response = await http.get(Uri.parse(url));
    final result = response.body;
    final Map<String, dynamic> labels = jsonDecode(result);
    return labels[index.toString()];
  }
}
