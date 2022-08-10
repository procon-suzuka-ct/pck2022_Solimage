//import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
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
      return;
    }
  }
}
