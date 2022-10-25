import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String uid; //userID
  String name; //userName
  List<int> groups = []; //所属しているグループ
  List<String> histories = []; //検索履歴
  List<int> favorites = []; //お気に入り
  List<int> _expDatas = []; //作成したデータ
  List<int> _goodDatas = []; //高評価したデータ
  List<int> _badDatas = []; //低評価したデータ

  List<int> get expDatas => _expDatas;
  List<int> get goodDatas => _goodDatas;
  List<int> get badDatas => _badDatas;

  AppUser({required this.uid, required this.name});

  AppUser.fromJson(Map<String, Object?> json)
      : uid = json['uid'] as String,
        name = json['name'] as String,
        groups = (json['groups'] as List<dynamic>).cast<int>(),
        histories = (json['histories'] as List<dynamic>).cast<String>(),
        favorites = (json['favorites'] as List<dynamic>).cast<int>(),
        _expDatas = (json['expDatas'] as List<dynamic>).cast<int>(),
        _goodDatas = (json['goodDatas'] as List<dynamic>).cast<int>(),
        _badDatas = (json['badDatas'] as List<dynamic>).cast<int>();

  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'name': name,
      'groups': groups,
      'histories': histories,
      'favorites': favorites,
      'expDatas': _expDatas,
      'goodDatas': _goodDatas,
      'badDatas': _badDatas,
    };
  }

  static DocumentReference<AppUser> _getRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .withConverter<AppUser>(
            fromFirestore: ((snapshot, _) =>
                AppUser.fromJson(snapshot.data()!)),
            toFirestore: (value, _) => value.toJson());
  }

  //ユーザー情報をFirestoreに保存する
  Future<void> save() async {
    await _getRef(uid).set(this);
  }

  void addExpData(int expDataID) {
    if (_expDatas.contains(expDataID)) {
      return;
    } else {
      _expDatas.add(expDataID);
    }
    return;
  }

  void removeExpData(int expDataID) {
    if (_expDatas.contains(expDataID)) {
      _expDatas.remove(expDataID);
    }
    return;
  }

  void setData(String uid, String name) {
    this.uid = uid;
    this.name = name;
    return;
  }

  Stream<DocumentSnapshot> listener() {
    return _getRef(uid).snapshots();
  }

  //ユーザー情報をFirestoreから取得する
  static Future<AppUser?> getUser(String uid) async {
    final doc = await _getRef(uid).get();
    return doc.data();
  }

  Future<void> addGoodData(int expDataID) async {
    if (_goodDatas.contains(expDataID)) {
      return;
    } else {
      _goodDatas.add(expDataID);
    }
    save();
    return;
  }

  Future<void> addBadData(int expDataID) async {
    if (_badDatas.contains(expDataID)) {
      return;
    } else {
      _badDatas.add(expDataID);
    }
    save();
    return;
  }

  Future<void> removeGoodData(int expDataID) async {
    if (_goodDatas.contains(expDataID)) {
      _goodDatas.remove(expDataID);
    }
    save();
    return;
  }

  Future<void> removeBadData(int expDataID) async {
    if (_badDatas.contains(expDataID)) {
      _badDatas.remove(expDataID);
    }
    save();
    return;
  }
}
