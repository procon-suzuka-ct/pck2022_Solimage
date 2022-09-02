class Coordinates {
  int _objNum = 0;
  List<List<int>> _objCoordinates = [];

  int get objNum => _objNum;
  List<List<int>> get objCoordinates => _objCoordinates;

  Coordinates({required int objNum, required List<List<int>> objCoordinates}) {
    _objNum = objNum;
    _objCoordinates = objCoordinates;
  }
}
