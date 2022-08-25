import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:solimage/utils/auth.dart';

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
    _dataId = 0;
  }

  void init() async {
    await generatId().then((value) => _dataId = value);
    return;
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
    if (Auth().currentUser()!.uid != _userId) {
      throw Exception('userId is not match');
    }
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

  Future<int> generatId() async {
    final docs =
        (await FirebaseFirestore.instance.collection('expData').get()).docs;
    List<String> ids = [];
    for (final doc in docs) {
      ids.add(doc.id);
    }
    while (true) {
      const max = 9999999999;
      const min = 1000000000;
      final num = Random().nextInt(max - min) + min;
      final numString = num.toString();
      bool isExist = false;
      for (final id in ids) {
        if (id == numString) {
          isExist = true;
          break;
        }
      }
      if (!isExist) {
        return num;
      }
    }
  }

  //Firestoreに保存する
  Future<void> save() async {
    if (Auth().currentUser()!.uid != _userId) {
      throw Exception('userId is not match');
    }
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
