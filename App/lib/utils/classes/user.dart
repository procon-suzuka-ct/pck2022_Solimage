import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String uid; //userID
  String name; //userName
  List<int> groups = []; //所属しているグループ
  List<String> histories = []; //検索履歴
  List<int> favorites = []; //お気に入り
  List<int> _expDatas = []; //作成したデータ

  List<int> get expDatas => _expDatas;

  AppUser({required this.uid, required this.name});

  AppUser.fromJson(Map<String, Object?> json)
      : uid = json['uid'] as String,
        name = json['name'] as String,
        groups = (json['groups'] as List<dynamic>).cast<int>(),
        histories = (json['histories'] as List<dynamic>).cast<String>(),
        favorites = (json['favorites'] as List<dynamic>).cast<int>(),
        _expDatas = (json['expDatas'] as List<dynamic>).cast<int>();

  Map<String, Object?> toJson(){
    return {
      'uid': uid,
      'name': name,
      'groups': groups,
      'histories': histories,
      'favorites': favorites,
      'expDatas': _expDatas,
    };
  }

  //ユーザー情報をFirestoreに保存する
  Future<void> save() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'groups': groups,
      'histories': histories,
      'favorites': favorites,
      'expDatas': _expDatas,
    });
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

  //ユーザー情報をFirestoreから取得する
  static Future<AppUser?> getUser(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid).withConverter<AppUser>(
      fromFirestore: (snapshot, _) => AppUser.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );
    final doc = await userRef.get();
    return doc.data();
  }
}
