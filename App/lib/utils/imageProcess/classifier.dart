import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:solimage/utils/imageProcess/imageUtil.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:collection/collection.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class Classifier {
  //singleton
  static final Classifier _singleton = Classifier._internal();
  static Classifier get instance => _singleton;
  // 変更済み（ここから）
  Classifier._internal() {
    _interpreterOptions.threads = 1;
  }

  bool isInited = false;

  late Interpreter _interpreter;
  final _interpreterOptions = InterpreterOptions();

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorBuffer _outputBuffer;
  late TfLiteType _inputType;
  late TfLiteType _outputType;
  late TensorImage _inputImage;
  late File _modelFile;

  DequantizeOp get _preProcessNormalizeOp => DequantizeOp(0, 255);
  NormalizeOp get _postProcessNormalizeOp => NormalizeOp(0, 1);

  late List<String> labels;
  late SequentialProcessor<TensorBuffer> _probabilityProcessor;

  Future<void> init() async {
    if (isInited) return;
    var modelLoad = loadModel();
    var labelLoad = loadLabels();
    await Future.wait([modelLoad, labelLoad]);
    isInited = true;
  }

  Future<void> loadLabels() async {
    labels = await FileUtil.loadLabels("assets/labels.txt");
    return;
  }

  Future<void> loadModel() async {
    try {
      // 量子化したモデルは動かすとクラッシュするのでfirebaseは使わない
      /*_modelFile = await FirebaseModelDownloader.instance
          .getModel(
              "solimage-special",
              FirebaseModelDownloadType.localModel,
              FirebaseModelDownloadConditions(
                iosAllowsCellularAccess: true,
                iosAllowsBackgroundDownloading: false,
                androidChargingRequired: false,
                androidWifiRequired: false,
                androidDeviceIdleRequired: false,
              ))
          .then((value) => value.file);*/
      _interpreter = await Interpreter.fromAsset("model.tflite",
          options: _interpreterOptions);
      //Interpreter.fromFile(_modelFile, options: _interpreterOptions);
      _inputShape = _interpreter.getInputTensor(0).shape;
      _inputType = _interpreter.getInputTensor(0).type;
      _outputShape = _interpreter.getOutputTensor(0).shape;
      _outputType = _interpreter.getOutputTensor(0).type;
      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _probabilityProcessor =
          TensorProcessorBuilder().add(_postProcessNormalizeOp).build();
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
  /// final label = result.label;
  /// ```
  ///
  TensorImage _preProcess() {
    final width = _inputShape[1];
    final height = _inputShape[2];
    final resizeRatio =
        max(height / _inputImage.height, width / _inputImage.width);
    final resizedWidth = (_inputImage.width * resizeRatio).floor();
    final resizedHeight = (_inputImage.height * resizeRatio).floor();
    return ImageProcessorBuilder()
        .add(ResizeOp(
            resizedHeight, resizedWidth, ResizeMethod.NEAREST_NEIGHBOUR))
        .add(ResizeWithCropOrPadOp(
          height,
          width,
        ))
        .build()
        .process(_inputImage);
  }

  /// This method is return [List] of [Category]
  ///
  /// The returned List is sorted by probability
  ///
  /// usage:
  /// ```dart
  /// final result = await Classifier.instance.predict(image);
  /// var top = result[0];
  /// var label = top.label;
  /// var score = top.score;
  /// ```
  Future<List<Category>> predict(Object image) async {
    if (!isInited) await init();
    if (image is CameraImage) {
      image = ImageUtils.convertYUV420ToImage(image);
    }
    if (image is! Image) {
      throw Exception("Invalid image type");
    }
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = _preProcess();

    print(_inputShape);

    _interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    Map<String, double> labeledProb = TensorLabel.fromList(
            labels, _probabilityProcessor.process(_outputBuffer))
        .getMapWithFloatValue();
    final pred = getSortedProbability(labeledProb);
    List<Category> categories = [];
    for (var result in pred) {
      categories.add(Category(result.key, result.value));
    }
    return categories;
  }

  List<MapEntry<String, double>> getSortedProbability(
      Map<String, double> labeledProb) {
    var pq = PriorityQueue<MapEntry<String, double>>(compare);
    pq.addAll(labeledProb.entries);

    // 1~3位までの確率を表示
    List<MapEntry<String, double>> top3 = [];
    while (pq.isNotEmpty) {
      top3.add(pq.removeFirst());
    }

    return top3;
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

  int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
    if (e1.value > e2.value) {
      return -1;
    } else if (e1.value == e2.value) {
      return 0;
    } else {
      return 1;
    }
  }

  List<int> getPicShape() {
    return [_inputShape[1], _inputShape[2]];
  }
}
