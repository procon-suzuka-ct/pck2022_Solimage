import 'package:cloud_firestore/cloud_firestore.dart';

class ExpData {
  late final int _dataId;
  late final String _userId;
  late final int? rootId;
  late final List<int> childIds;

  late String _word;
  late String _meaning;

  //5W1H
  String? _why;
  String? _what;
  String? _where;
  String? _when;
  String? _who;
  String? _how;

  String? _imageUrl;

  ExpData({required String word, required String meaning, this.rootId}) {
    _word = word;
    _meaning = meaning;
    rootId ??= 0;
  }

  void setData(
      {String? word,
      String? meaning,
      String? why,
      String? what,
      String? where,
      String? when,
      String? who,
      String? how,
      String? imageUrl}) {
    _word = word ?? _word;
    _meaning = meaning ?? _meaning;
    _why = why ?? _why;
    _what = what ?? _what;
    _where = where ?? _where;
    _when = when ?? _when;
    _who = who ?? _who;
    _how = how ?? _how;
    _imageUrl = imageUrl ?? _imageUrl;
    return;
  }

  //Firestoreに保存する
  Future<void> save() async {
    await FirebaseFirestore.instance
        .collection('expData')
        .doc(_dataId.toString())
        .set({
      'userId': _userId,
      'word': _word,
      'meaning': _meaning,
      'why': _why,
      'what': _what,
      'where': _where,
      'when': _when,
      'who': _who,
      'how': _how,
      'imageUrl': _imageUrl,
      'childIds': childIds,
      'rootId': rootId,
    });
  }

  //Firestoreから取得する
  static Future<ExpData?> getExpData(int dataId) async {
    final doc = await FirebaseFirestore.instance
        .collection('expData')
        .doc(dataId.toString())
        .get();
    if (doc.exists) {
      final expData = ExpData(
        word: doc['word'],
        meaning: doc['meaning'],
        rootId: doc['rootId'],
      );
      expData.setData(
        why: doc['why'],
        what: doc['what'],
        where: doc['where'],
        when: doc['when'],
        who: doc['who'],
        how: doc['how'],
        imageUrl: doc['imageUrl'],
      );
      expData._dataId = doc['dataId'];
      expData._userId = doc['userId'];
      expData.childIds = doc['childIds'];

      return expData;
    } else {
      return null;
    }
  }
}
