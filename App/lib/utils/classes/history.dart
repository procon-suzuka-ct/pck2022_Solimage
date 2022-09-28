import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class History {
  final String _uid;
  final String _word;
  late String _imageDataUrl;
  final int _year;
  final int _month;
  final int _day;

  String get uid => _uid;
  String get word => _word;
  String get imageDataUrl => _imageDataUrl;
  int get year => _year;
  int get month => _month;
  int get day => _day;

  History(this._uid, this._word, this._year, this._month, this._day);

  History.fromJson(Map<String, Object?> json)
      : _uid = json['uid'] as String,
        _word = json['word'] as String,
        _imageDataUrl = json['imageDataUrl'] as String,
        _year = json['year'] as int,
        _month = json['month'] as int,
        _day = json['day'] as int;

  Map<String, Object?> toJson() {
    return {
      'uid': _uid,
      'word': _word,
      'imageDataUrl': _imageDataUrl,
      'year': _year,
      'month': _month,
      'day': _day,
    };
  }

  static CollectionReference<Map<String, dynamic>> _getRef(String uid) {
    return FirebaseFirestore.instance
        .collection('histories')
        .doc()
        .collection(uid);
  }

  //ユーザー情報をFirestoreに保存する
  Future<void> _save() async {
    await _getRef(uid).doc(word).set(toJson());
  }

  static Future<List<History>> getHistories(String uid) async {
    final snapshot = await _getRef(uid).get();
    final data = [for (var doc in snapshot.docs) History.fromJson(doc.data())];
    return data;
  }

  Future<void> delete() async {
    await _getRef(uid).doc(word).delete();
  }

  Future<void> deleteAll() async {
    final snapshot = await _getRef(uid).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<String> save(String imagePath) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('histories/$uid/$word${DateTime.now()}.jpg');
    File file = File(imagePath);
    final task = ref.putFile(file);
    final snapshot = await task;
    final url = await snapshot.ref.getDownloadURL();
    _imageDataUrl = url;
    await _save();
    return url;
  }
}
