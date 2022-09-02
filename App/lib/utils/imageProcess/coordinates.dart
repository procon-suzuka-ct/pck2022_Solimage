class Coordinates {
  int _objNum = 0;
  List<List<double>> _objCoordinates = [];

  int get objNum => _objNum;
  List<List<double>> get objCoordinates => _objCoordinates;

  Coordinates(
      {required int objNum, required List<List<double>> objCoordinates}) {
    _objNum = objNum;
    _objCoordinates = objCoordinates;
  }
}
