import 'package:image/image.dart';
import 'dart:async';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  //singleton
  static final Classifier _singleton = Classifier._internal();
  static Classifier get instance => _singleton;
  Classifier._internal();

  late Interpreter _interpreter;
  late InterpreterOptions _interpreterOptions;

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorBuffer _outputBuffer;
  late TfLiteType _inputType;
  late TfLiteType _outputType;

  late final String _modelName;

  final NormalizeOp _preProcessNormalizeOp = NormalizeOp(0, 1);

  Classifier(this._modelName) {
    _interpreterOptions = InterpreterOptions();
    _interpreterOptions.threads = 1;

    loadModel();
  }

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
      _interpreter =
          await Interpreter.fromAsset(_modelName, options: _interpreterOptions);

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

  List<double> predict(Image image) {
    TensorImage inputImage = TensorImage(_inputType);

    inputImage.loadImage(image);
    inputImage = preProcess(inputImage);

    _interpreter.run(inputImage.buffer, _outputBuffer.getBuffer());
    return _outputBuffer.getDoubleList();
  }
}
